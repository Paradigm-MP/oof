World = class()

function World:__init()
    self.timestep_enabled = false
    self.time = {hours = 12, minutes = 0, seconds = 0}
    self.weather = "SUNNY"
    self.prev_weather = self.weather
    self.timescale = 1
    self.blackout = false

    -- Network events for syncing world properties
    Network:Subscribe("API/World/InitialSync", function(args) self:InitialSync(args) end)
    Network:Subscribe("API/World/SetTimeScale", function(args) self:SetTimeScale(args.scale) end)
    Network:Subscribe("API/World/SetBlackout", function(args) self:SetBlackout(args.blackout) end)
    --Network:Subscribe("API/World/SetMixedWeather", function(args) self:SetTimeScale(args.scale) end)
    Network:Subscribe("API/World/SetWeather", function(args) self:SetWeather(args.weather) end)
    Network:Subscribe("API/World/SetTime", function(args) self:SetTime(args.time.hours, args.time.minutes, args.time.seconds) end)
    Network:Subscribe("API/World/SetTimestepEnabled", function(args) self:SetTimestepEnabled(args.enabled) end)
end

--[[
    Initial sync of world properties when the player joins.
]]
function World:InitialSync(args)
    World:SetTime(args.time.hours, args.time.minutes, args.time.seconds)
    self:SetBlackout(args.blackout)
    self:SetWeather(args.weather)
    self:SetTimestepEnabled(args.timestep_enabled)
end

--[[
    Sets time scale, range 0-1
    1 is normal, 0 is super slow, anything between is slow motion
]]
function World:SetTimeScale(scale)
    self.timescale = tofloat(scale)
    SetTimeScale(self.timescale)
end

--[[
    Turns off/on all the lights in the world
]]
function World:SetBlackout(blackout)
    self.blackout = blackout
    SetArtificialLightsState(blackout)
end

--[[
    Sets the weather as a mix of two weathers
]]
function World:SetMixedWeather(weather1, weather2, weather2percent)

    --SetWeatherTypeTransition
    -- TODO
    -- https://runtime.fivem.net/doc/natives/#_0x578C752848ECFA0C

end

--[[
    Sets the world weather. Valid weather strings are:
    
    "RAIN",
    "FOG",
    "SNOWLIGHT",
    "THUNDER",
    "BLIZZARD",
    "SNOW",
    "MISTY",
    "SUNNY",
    "HIGHPRESSURE",
    "CLEARING",
    "SLEET",
    "DRIZZLE",
    "SHOWER",
    "SNOWCLEARING",
    "OVERCASTDARK",
    "THUNDERSTORM",
    "SANDSTORM",
    "HURRICANE",
    "HAIL",
    "WHITEOUT",
    "GROUNDBLIZZARD",

    Adapted from: https://github.com/TomGrobbe/vSync/blob/master/vSync/vs_client.lua
]]
function World:SetWeather(weather, transition_time)
    --[[SetWeatherTypeTransition(
        GetHashKey(self.weather), 
        GetHashKey(weather), 
        transition_time == nil and 0.5 or transition_time,
        true
        )]]
    --Chat:Print("Entered cWorld:SetWeather to {" .. tostring(weather) .. "}")
    self.weather = weather
    Citizen.InvokeNative(0x59174F1AFE095B5A, GetHashKey(weather), true, false, true, true, false)
end


--[[
    Sets the world time.

    hours - 0-23
    minutes - 0-59
    seconds - 0-59
]]
function World:SetTime(hours, minutes, seconds)
    print("Setting time to {", hours, "}, {", minutes, "}, {", seconds, "}")
    NetworkClockTimeOverride(hours, minutes or 0, seconds or 0)
    --NetworkOverrideClockTime(hours, minutes, seconds)
    --SetClockTime(hours, minutes, seconds)
    --AdvanceClockTimeTo(hours, minutes, seconds)
    self.last_set_time = {hours = hours, minutes = minutes, seconds = seconds}
end

--[[
    Enables/disables world timestep.
]]
function World:SetTimestepEnabled(enabled)
    self.timestep_enabled = enabled
    PauseClock(not self.timestep_enabled)

    if not self.timestep_enabled then
        self.last_set_time = self:GetTime()
    end

    --Citizen.CreateThread(function()
    --    while not self.timestep_enabled do
    --        self:SetTime(self.last_set_time.hours, self.last_set_time.minutes, self.last_set_time.seconds)
    --        Wait(500)
    --    end
    --end)

end

function World:GetTimestepEnabled()
    return self.timestep_enabled
end

function World:GetTimeScale()
    return self.timescale
end

--[[
    Gets the world time

    returns
    hours, minutes, seconds (ints)
]]
function World:GetTime()
    local hours, minutes, seconds = GetClockHours(), GetClockMinutes(), GetClockSeconds()
    return {hours = hours, minutes = minutes, seconds = seconds}
end

function World:GetBlackout()
    return self.blackout
end

function World:GetWeather()
    return self.weather
end

World = World()