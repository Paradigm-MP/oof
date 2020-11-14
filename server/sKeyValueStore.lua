KeyValueStore = class()

--[[
 * KeyValueStore
 * 
 * KeyValueStore is a simple :Get() and :Set() value storage utility
 * that persists the values in the MySQL database.
 * Caching occurs on every operation (Get, Set, Delete).
 * Supported types: string, number, boolean, table (converted to json string), nil
]]
function KeyValueStore:__init()
    SQL:Execute([[CREATE TABLE IF NOT EXISTS `key_value_store` (`key` VARCHAR(100) NOT NULL PRIMARY KEY, `value_type` VARCHAR(50), `value` VARCHAR(1000))]])
    self.max_key_length = 100
    self.max_value_length = 1000

    -- in order to support immediately calling :Get after a :Set, we cache values for a short period of time (at least 1 frame)
    self.cached_values = {}
    self.min_cache_time = 1000 -- the minimum amount of time (ms) that values will be cached
    self.remove_stale_cache_values_interval = 1000 -- how often (ms) to remove stale cache values

    self.outstanding_get_callbacks = {}

    self:RemoveStaleCachedValuesThread()
    
    --[[
    RegisterCommand("s", function(source, args, rawCommand)
        KeyValueStore:Set("TestKey", math.random(1, 100))
    end)

    RegisterCommand("s2", function(source, args, rawCommand)
        KeyValueStore:Set("TestKey2", math.random(1, 100))
    end)

    RegisterCommand("g", function(source, args, rawCommand)
        KeyValueStore:Get("TestKey", function(value)
            print(value)
            print(type(value))
        end)
    end)

    RegisterCommand("del", function(source, args, rawCommand)
        KeyValueStore:Delete("TestKey")
    end)

    RegisterCommand("mg", function(source, args, rawCommand)
        local values_to_get = {"TestKey", "TestKey2"}
        KeyValueStore:Get(values_to_get, function(values)
            print("values: ", values)
            if values then
                output_table(values)
            end
        end)
    end)
    ]]
    
end

function KeyValueStore:Set(key, value, callback)
    assert(type(key) == "string", "KeyValueStore key must be a string")
    assert(string.len(key) <= self.max_key_length, "KeyValueStore key must be less than " .. tostring(self.max_key_length))
    local value_type = type(value)
    local cmd = [[INSERT INTO `key_value_store` (`key`, `value_type`, `value`) VALUES (@key, @value_type, @value) ON DUPLICATE KEY UPDATE `value`=@value, `value_type`=@value_type;]]

    if value == nil then
        self:Delete(key)
        return
    end

    local serialized_value = self:SerializeValue(value_type, value)
    assert(string.len(serialized_value) <= self.max_value_length, "KeyValueStore value must be less than " .. tostring(self.max_value_length))

    self:CacheValue(key, value)

    local params = {
        ["@key"] = key,
        ["@value"] = self:SerializeValue(value_type, value),
        ["@value_type"] = value_type
    }

    SQL:Execute(cmd, params, function(rows)
        if callback then
            callback()
        end
    end)
end

-- returns nil if key does not exist
function KeyValueStore:Get(key, callback)
    assert(type(key) == "string" or type(key) == "table", "KeyValueStore:Get key must be a string or table of strings")
    if type(key) == "table" then
        KeyValueStore:GetMultiple(key, callback)
        return
    end
    assert(string.len(key) <= self.max_key_length, "KeyValueStore key must be less than " .. tostring(self.max_key_length))
    local query = [[SELECT `value`, `value_type` FROM `key_value_store` WHERE `key`=@key]]
    local params = {
        ["@key"] = key
    }

    if self.cached_values[key] then
        self.cached_values[key].timer:Restart()
        self.__current_callback_key = key
        callback(self.cached_values[key].value)
        return
    end

    -- called :Get but still waiting on the same :Get
    if self.outstanding_get_callbacks[key] then
        table.insert(self.outstanding_get_callbacks[key], {callback = callback})
        return
    else
        self.outstanding_get_callbacks[key] = {
            {callback = callback}
        }
    end

    SQL:Fetch(query, params, function(result)
        if callback then
            local value = result[1] and result[1].value or nil
            local value_type = result[1] and result[1].value_type or nil
            if value then
                local deserialized_value = self:DeserializeValue(value_type, value)
                self:CacheValue(key, deserialized_value)
                self:CallGetCallbacks(key, deserialized_value)
            else
                -- either value doesnt exist or no result
                self:CallGetCallbacks(key, nil)
            end
        end
    end)
end

function KeyValueStore:GetMultiple(keys, callback)
    local key_count = count_table(keys)
    local requests_completed = 0
    local values = {}
    local function get_callback(value)
        values[KeyValueStore.__current_callback_key] = value
        requests_completed = requests_completed + 1
        if requests_completed == key_count then
            callback(values)
        end
    end

    for key_index, key in ipairs(keys) do
        KeyValueStore:Get(key, get_callback)
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

function KeyValueStore:Delete(key, callback)
    assert(type(key) == "string", "KeyValueStore key must be a string")
    local cmd = [[DELETE FROM `key_value_store` WHERE `key` = @key;]]

    local params = {
        ["@key"] = key
    }

    self:CacheValue(key, nil)

    -- we want the Delete to be instantaneous so any outstanding get requests are handled with a nil return value (aka doesn't exist)
    self:CallGetCallbacks(key, nil)

    SQL:Execute(cmd, params, function()
        if callback then
            callback()
        end
    end)
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