local OgLuaPrint = print

-- format time to have a 0 in front if its short
local function f_time(time)
    return time < 10 and "0" .. time or time
end

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
