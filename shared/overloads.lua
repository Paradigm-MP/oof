-- This file is where changes to existing superglobals (either in platform API or Lua itself) can be added via overloading
-- This allows us to change the behavior of these superglobals while keeping our code's vocabulary simple. It also makes refactoring much simpler in some cases.
-- adds print(), tostring(), and type() support for the object-oriented structure

IsTest = true

local OgLuaType = type -- we maintain a reference to the original superglobal function
function type(variable) -- then we redefine the superglobal, and add logic on top of the original superglobal function
    if OgLuaType(variable) == "table" and variable.__class_instance and variable.__type then
        return variable.__type
    else
        return OgLuaType(variable)
    end
end

local OgLuaTostring = tostring
function tostring(variable)
    if OgLuaType(variable) == "table" and variable.__class_instance then
        return variable:tostring()
    else
        return OgLuaTostring(variable)
    end
end

-- format time to have a 0 in front if its short
local function f_time(time)
    return time < 10 and "0" .. time or time
end

local OgLuaPrint = print
function print(...)
    local args = {...}
    local output_str = string.format("%s[%s]%s", 
        "^5", tostring(GetCurrentResourceName()), "^7")

    if IsServer then
        local t = os.date("*t", os.time())
        output_str = output_str .. " [" .. f_time(t.hour) .. ":" .. f_time(t.min) .. ":" .. f_time(t.sec) .. "]: "
    elseif IsClient then
        local year, month, day, hour, min, sec = GetPosixTime()
        output_str = output_str .. " [" .. f_time(hour) .. ":" .. f_time(min) .. ":" .. f_time(sec) .. "]: "
    end

    for index, arg in ipairs(args) do
        output_str = output_str .. tostring(arg)
    end

    OgLuaPrint(output_str)
end

local char = string.char
local insert = table.insert
local function string_to_number(str)
    if str:len() < 6 then
        local numeric_representations = {}
        local digits = 0
        for c in str:gmatch('.') do
            --print("number: ", c:byte())
            --print("type(number): ", type(c:byte()))
            insert(numeric_representations, c:byte())
        end
        return tonumber(table.concat(numeric_representations))
    else
        local numeric_representation = 0
        for c in str:gmatch('.') do
            numeric_representation = numeric_representation + c:byte()
        end
        return numeric_representation
    end
end

local OgMathRandomseed = math.randomseed
function math.randomseed(x)
    local number_form = x
    if type(x) == 'string' then
        number_form = string_to_number(x)
    end

    --print("number_form:", number_form)
    --print("type number form:", type(number_form))

    OgMathRandomseed(number_form)
end

