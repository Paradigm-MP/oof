KeyValueStore = class()

--[[
 * KeyValueStore
 * 
 * KeyValueStore is a simple :Get() and :Set() value storage utility
 * that persists the values in the MySQL database.
 * Caching occurs on every operation (Get, Set, Delete).
 * Supported types: string, number, boolean, table (converted to json string), nil
]]

-- the minimum amount of time (ms) that values will be cached
KeyValueStore.MinimumCacheTime = 1000

-- how often (ms) to remove stale cache entries
KeyValueStore.CacheClearInterval = 1000

-- The minimum amount of time an operation will be cached is: KeyValueStore.MinimumCacheTime
-- The maximum amount of time an operation will be cached is calculated as: KeyValueStore.MinimumCacheTime + KeyValueStore.CacheClearInterval

function KeyValueStore:__init()
    SQL:Execute([[CREATE TABLE IF NOT EXISTS `key_value_store` (`key` VARCHAR(200) NOT NULL PRIMARY KEY, `value_type` VARCHAR(50), `value` TEXT)]])
    self.max_key_length = 200
    self.max_value_length = 65000

    -- in order to support immediately calling :Get after a :Set, we cache values for a short period of time (at least 1 frame)
    self.cached_values = {}
    self.min_cache_time = KeyValueStore.MinimumCacheTime
    self.remove_stale_cache_values_interval = KeyValueStore.CacheClearInterval

    self.outstanding_get_callbacks = {}

    self:RemoveStaleCachedValuesThread()
    
end

function KeyValueStore:Set(args)
    assert(type(args) == "table", "KeyValueStore:Set requires a table of arguments")
    assert(type(args.key) == "string", "KeyValueStore:Set 'key' argument must be a string")
    assert(string.len(args.key) <= self.max_key_length, "KeyValueStore:Set 'key' argument must be less than " .. tostring(self.max_key_length))
    assert(not args.synchronous or (args.synchronous and not args.callback), "KeyValueStore:Set does not accept a 'callback' argument when the 'synchronous' argument is true")
    local value_type = type(args.value)
    local cmd = [[INSERT INTO `key_value_store` (`key`, `value_type`, `value`) VALUES (@key, @value_type, @value) ON DUPLICATE KEY UPDATE `value`=@value, `value_type`=@value_type;]]

    if args.value == nil then
        self:Delete(args.key, args.callback, args.synchronous)
        return
    end

    local serialized_value = self:SerializeValue(value_type, args.value)
    if string.len(serialized_value) > self.max_value_length then
        error("KeyValueStore:Set serialized value length exceeds the maximum length of " .. tostring(self.max_value_length) .. " for the key '" .. args.key .. "'. Please reduce the amount of information you are trying to store.")
    end

    self:CacheValue(args.key, args.value)

    local params = {
        ["@key"] = args.key,
        ["@value"] = serialized_value,
        ["@value_type"] = value_type
    }

    local has_database_callback = false

    SQL:Execute(cmd, params, function(rows)
        if args.synchronous then
            has_database_callback = true
        end

        if not args.synchronous and args.callback then
            args.callback()
        end
    end)

    if args.synchronous then
        local response_timer = Timer()
        while not has_database_callback do
            Wait(5)
            if response_timer:GetSeconds() > 4 then
                print("KeyValueStore:Set timed out! No database callback within 4 seconds")
                break
            end
        end

        return
    end
end

--[[
    Returns the value associated with a key from the KeyValueStore
    Returns nil if the key does not exist
    Either the 'key' or 'keys' argument is used to fetch 1 or potentially multiple keys respectively

    args: (in table)
        key - (string) the singular key to search for
        keys - (sequential table of strings) the list of keys to search for
        synchronous (boolean) 
            whether to delay the execution of the current thread (synchronous = true) until we can return the result,
            otherwise the 'callback' function is called with the result (synchronous = false or nil)
        callback (function) when the 'synchronous' argument is false or nil, this function is called with the result
]]
function KeyValueStore:Get(args)
    assert(type(args) == "table", "KeyValueStore:Get requires a table of arguments")
    assert((type(args.key) == "string" or type(args.keys) == "table") and not (args.key and args.keys), "KeyValueStore:Get requires either a 'key' argument of type string, or a 'keys' argument of type table")
    assert(args.synchronous or args.callback, "KeyValueStore:Get requires a 'callback' argument of type function when the 'synchronous' argument is nil or false")
    assert(not args.synchronous or (args.synchronous and not args.callback), "KeyValueStore:Get does not accept a 'callback' argument when the 'synchronous' argument is true")
    if type(args.keys) == "table" then
        for _, key in pairs(args.keys) do
            -- TODO: output the key that is too long
            assert(string.len(key) <= self.max_key_length, "KeyValueStore key must be less than " .. tostring(self.max_key_length))
        end

        if args.synchronous then
            return KeyValueStore:GetMultiple(args)
        else
            KeyValueStore:GetMultiple(args)
            return
        end
    end

    assert(string.len(args.key) <= self.max_key_length, "KeyValueStore key must be less than " .. tostring(self.max_key_length))
    local query = [[SELECT `value`, `value_type` FROM `key_value_store` WHERE `key`=@key]]
    local params = {
        ["@key"] = args.key
    }

    if self.cached_values[args.key] then
        self.cached_values[args.key].timer:Restart()
        self.__current_callback_key = args.key

        if args.synchronous then
            return self.cached_values[args.key].value
        else
            args.callback(self.cached_values[args.key].value)
            return
        end
    end

    if not args.synchronous then
        -- called :Get but still waiting on the same :Get
        if self.outstanding_get_callbacks[args.key] then
            table.insert(self.outstanding_get_callbacks[args.key], {callback = args.callback})
            return
        else
            self.outstanding_get_callbacks[args.key] = {
                {callback = args.callback}
            }
        end
    end

    local has_sql_result = false
    local sql_result

    SQL:Fetch(query, params, function(result)
        local value = result[1] and result[1].value or nil
        local value_type = result[1] and result[1].value_type or nil

        if not args.synchronous and args.callback then
            if value then
                local deserialized_value = self:DeserializeValue(value_type, value)
                self:CacheValue(args.key, deserialized_value)
                self:CallGetCallbacks(args.key, deserialized_value)
            else
                -- either value doesnt exist or no result
                self:CallGetCallbacks(args.key, nil)
            end
        end

        if args.synchronous then
            if value then
                local deserialized_value = self:DeserializeValue(value_type, value)
                self:CacheValue(args.key, deserialized_value)
                sql_result = deserialized_value
            end
            has_sql_result = true
        end
    end)

    local response_timer = Timer()
    if args.synchronous then
        while not has_sql_result do
            Wait(5)
            if response_timer:GetSeconds() > 4 then
                print("KeyValueStore:Get timed out! No response received within 4 seconds")
                return nil
            end
        end

        return sql_result
    end
end

function KeyValueStore:GetMultiple(args)
    local values = {}

    if args.synchronous then
        for _, key in ipairs(args.keys) do
            values[key] = KeyValueStore:Get({key = key, synchronous = true})
        end
        return values
    else
        local key_count = count_table(args.keys)
        local requests_completed = 0

        local function get_callback(value)
            values[KeyValueStore.__current_callback_key] = value
            requests_completed = requests_completed + 1
            if requests_completed == key_count then
                args.callback(values)
            end
        end
    
        for key_index, key in ipairs(args.keys) do
            KeyValueStore:Get({key = key, callback = get_callback})
        end
    end
end

function KeyValueStore:SerializeValue(value_type, value)
    if value_type == "table" then
        -- return json.encode(value, {indent = false})
        return JsonOOF.encode(value)
    elseif value_type == "boolean" then
        if value then return "true" else return "false" end
    end

    return value
end

function KeyValueStore:DeserializeValue(value_type, value)
    if value_type == "number" then
        return tonumber(value)
    elseif value_type == "table" then
        return JsonOOF.decode(value)
    elseif value_type == "boolean" then
        if value == "true" then return true else return false end
    end

    return value
end

function KeyValueStore:Delete(key, callback, synchronous)
    assert(type(key) == "string", "KeyValueStore:Delete key must be a string")
    assert(not callback or type(callback) == "function", "KeyValueStore:Delete 'callback' argument must be a function or not nil")
    local cmd = [[DELETE FROM `key_value_store` WHERE `key` = @key;]]

    local params = {
        ["@key"] = key
    }

    self:CacheValue(key, nil)

    -- we want the Delete to be instantaneous so any outstanding get requests are handled with a nil return value (aka doesn't exist)
    self:CallGetCallbacks(key, nil)

    local has_database_callback = false

    SQL:Execute(cmd, params, function()
        if synchronous then
            has_database_callback = true
        end
        if not synchronous and callback then
            callback()
        end
    end)

    if synchronous then
        local response_timer = Timer()
        while not has_database_callback do
            Wait(5)
            if response_timer:GetSeconds() > 4 then
                print("KeyValueStore:Delete timed out! No database callback within 4 seconds")
                break
            end
        end

        return
    end
end

function KeyValueStore:CacheValue(key, value)
    self.cached_values[key] = {
        timer = Timer(),
        value = value
    }
end

function KeyValueStore:CallGetCallbacks(key, value)
    if self.outstanding_get_callbacks[key] then
        for _, callback_data in ipairs(self.outstanding_get_callbacks[key]) do
            self.__current_callback_key = key
            callback_data.callback(value)
        end
        self.outstanding_get_callbacks[key] = nil
    end
end

function KeyValueStore:RemoveStaleCachedValuesThread()
    Citizen.CreateThread(function()
        while true do
            Wait(self.remove_stale_cache_values_interval)

            -- store the keys to remove in a separate table and remove outside of self.cached_values loop to prevent concurrent modification issues
            local keys_to_remove = {}
            for key, cache_data in pairs(self.cached_values) do
                if cache_data.timer:GetMilliseconds() > self.min_cache_time then
                    table.insert(keys_to_remove, key)
                end
            end

            for _, key in ipairs(keys_to_remove) do
                self.cached_values[key].timer = nil
                self.cached_values[key] = nil
            end
        end
    end)
end

KeyValueStore = KeyValueStore()