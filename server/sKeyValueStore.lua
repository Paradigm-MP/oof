KeyValueStore = class()

-- TODO: object-oriented callback
-- TODO: description of class here
-- TODO: documentation
function KeyValueStore:__init()
    SQL:Execute([[CREATE TABLE IF NOT EXISTS `key_value_store` (`key` VARCHAR(100) NOT NULL PRIMARY KEY, `value_type` VARCHAR(50), `value` VARCHAR(1000))]])
    self.max_key_length = 100
    self.max_value_length = 1000

    -- in order to support immediately calling :Get after a :Set, we cache values for a short period of time (at least 1 frame)
    self.cached_values = {}
    self.min_cache_time = 1000 -- the minimum amount of time (ms) that values will be cached
    self.remove_stale_cache_values_interval = 1000 -- how often (ms) to remove stale cache values

    self:RemoveStaleCachedValuesThread()
end

function KeyValueStore:Set(key, value, callback)
    assert(type(key) == "string", "KeyValueStore key must be a string")
    assert(string.len(key) <= self.max_key_length, "KeyValueStore key must be less than " .. tostring(self.max_key_length))
    local value_type = type(value)
    local cmd = [[INSERT INTO `key_value_store` (`key`, `value_type`, `value`) VALUES (@key, @value_type, @value) ON DUPLICATE KEY UPDATE `value`=@value, `value_type`=@value_type;]]

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
    local query = [[SELECT `value`, `value_type` FROM `key_value_store` WHERE `key`=@key]]
    local params = {
        ["@key"] = key
    }

    if self.cached_values[key] then
        callback(self.cached_values[key].value)
        return
    end

    SQL:Fetch(query, params, function(result)
        if callback then
            local value = result[1] and result[1].value or nil
            local value_type = result[1] and result[1].value_type or nil
            if value then
                callback(self:DeserializeValue(value_type, value))
            else
                callback(nil)
            end
        end
    end)
end

function KeyValueStore:SerializeValue(value_type, value)
    if value_type == "table" then
        return json.encode(value, {indent = false})
    elseif value_type == "boolean" then
        if value then return "true" else return "false" end
    end

    return value
end

function KeyValueStore:DeserializeValue(value_type, value)
    if value_type == "number" then
        return tonumber(value)
    elseif value_type == "table" then
        return json.decode(value)
    elseif value_type == "boolean" then
        if value == "true" then return true else return false end
    end

    return value
end

function KeyValueStore:Delete(key)

end

function KeyValueStore:CacheValue(key, value)
    self.cached_values[key] = {
        timer = Timer(),
        value = value
    }
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