-- Pure Lua global utility functions (considered as additions to the vanilla Lua environment)
-- no class instances can be instantiated in this file

IsServer = IsDuplicityVersion() -- true if the machine this code runs on is the (single) server
IsClient = not IsServer -- true if the machine this code runs on is one of the clients / players connected to the server

CreateThread = Citizen.CreateThread

function unpack(t, i)
    i = i or 1
    if t[i] ~= nil then
      return t[i], unpack(t, i + 1)
    end
end

-- counts an associative Lua table (use #table for sequential tables)
function count_table(table)
    local count = 0

    for k, v in pairs(table) do
        count = count + 1
    end

    return count
end

function tofloat(num)
    return num / 1.0
end

-- general linear interpolation function
-- parameter t should be between 0.0 and 1.0
-- (0.0 is a and 1.0 is b)
function lerp(a, b, t)
    return a * (1 - t) + (b * t)
end

-- splits a string given a seperator
-- returns a sequential table of tokens, which could be empty
function split(input_str, seperator)
    if seperator == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(input_str, "([^" .. seperator .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function math.round(num, decimal_places)
    return tonumber(string.format("%." .. (decimal_places or 0) .. "f", num))
end

function math.clamp(value, lower, upper)
    return math.min(math.max(value, lower), upper)
end

function trim(s)
    return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

-- Allows string indexing with s[0], from http://lua-users.org/wiki/StringIndexing
getmetatable('').__index = function(str,i)
    if type(i) == 'number' then
        return string.sub(str,i,i)
    else
        return string[i]
    end
end

function sequence_contains(t, v)
    for _, _v in pairs(t) do
        if v == _v then return true end
    end
    return false
end

function random_table_value(t)
    local keys = {}
    for k in pairs(t) do table.insert(keys, k) end
    return t[keys[math.random(#keys)]]
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- does not keep same order
function shallow_copy(t)
    local new_table = {}
    for k, v in pairs(t) do
        new_table[k] = v
    end
    return new_table
end

function output_table(t)
    print("-----", t, "-----")
    for key, value in pairs(t) do
        if type(value) ~= "table" or (type(value) == "table" and value.__class_instance) then
            print("[", key, "]: ", value)
        else
            print(key .. " {")
            for k, v in pairs(value) do
                if type(v) ~= "table" or (type(value) == "table" and value.__class_instance) then
                    print("[", k, "]: ", v)
                else
                    print(k .. " {")
                    for k2, v2 in pairs(v) do
                        print("[", k2, "]: ", v2)
                    end
                    print("}")
                end
            end
            print("}")
        end
    end
    print("------------------------")
end

-- omitted keys is a table where key is index and value can be anything except false or 0
function random_weighted_table_value(weighted_table, omitted_keys)
    if not omitted_keys then
        omitted_keys = {}
    end

    local sum = 0
    for key, weight in pairs(weighted_table) do
        if not omitted_keys[key] then
            sum = sum + weight
        end
    end

    local rand = math.random() * sum
    local found
    for key, weight in pairs(weighted_table) do
        if not omitted_keys[key] then
            rand = rand - weight
            if rand < 0 then
                found = key
                break
            end
        end
    end

    return found
end