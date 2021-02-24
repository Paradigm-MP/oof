World = class()

function World:__init()
    self.timestep_enabled = false
    self.time = {hours = 12, minutes = 0, seconds = 0}
    self.weather = "SUNNY"
    self.prev_weather = self.weather
    self.timescale = 1
    self.blackout = false

    -- Network events for syncing world properties
    Network:Subscribe("API/World/InitialSync", self, self.InitialSync)
    Network:Subscribe("API/World/SetTimeScale", self, self.SetTimeScale)
    Network:Subscribe("API/World/SetBlackout", self, self.SetBlackout)
    --Network:Subscribe("API/World/SetMixedWeather", self,self:SetTimeScale(args.scale) end)
    Network:Subscribe("API/World/SetWeather", self, self.SetWeather)
    Network:Subscribe("API/World/SetTime", self, self.SetTime)
    Network:Subscribe("API/World/SetTimestepEnabled", self, self.SetTimestepEnabled)
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
    
    REDM weather types:
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

    FIVEM weather types:
    extrasunny, clear, neutral, smog, foggy, overcast, clouds, clearing, 
    rain, thunder, snow, blizzard, snowlight, xmas & halloween

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

    if IsRedM then
        -- TODO: implement for fivem (not sure if this works in fivem, needs testing)
        Citizen.InvokeNative(0x59174F1AFE095B5A, GetHashKey(weather), true, false, true, true, false)
    else
        -- Adapted from: https://github.com/TomGrobbe/vSync/blob/master/vSync/vs_client.lua
        Citizen.CreateThread(function()
            while true do
    
                if self.prev_weather ~= self.weather then
                    self.prev_weather = self.weather
                    SetWeatherTypeOverTime(self.weather, 15.0)
                    Citizen.Wait(15000)
                end
    
                Citizen.Wait(100)
                ClearOverrideWeather()
                ClearWeatherTypePersist()
                SetWeatherTypePersist(self.prev_weather)
                SetWeatherTypeNow(self.prev_weather)
                SetWeatherTypeNowPersist(self.prev_weather)
    
                if self.prev_weather == 'XMAS' then
                    SetForceVehicleTrails(true)
                    SetForcePedFootstepsTracks(true)
                else
                    SetForceVehicleTrails(false)
                    SetForcePedFootstepsTracks(false)
                end
            end
        end)
    end
end


--[[
    Sets the world time.

    hours - 0-23
    minutes - 0-59
    seconds - 0-59
]]
function World:SetTime(hours, minutes, seconds)
    -- print("Setting time to {", hours, "}, {", minutes, "}, {", seconds, "}")

    if IsRedM then
        NetworkClockTimeOverride(hours, minutes or 0, seconds or 0)
    else
        NetworkOverrideClockTime(hours, minutes, seconds)
    end
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

    Citizen.CreateThread(function()
       while not self.timestep_enabled do
           self:SetTime(self.last_set_time.hours, self.last_set_time.minutes, self.last_set_time.seconds)
           Wait(1000)
       end
    end)

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

function World:DisablePedSpawning()

    if IsFiveM then
        
        SetGarbageTrucks(0)
        SetRandomBoats(0)

        for i = 1, 15 do
			EnableDispatchService(i, false)
		end

        local SCENARIO_TYPES = {
            "DRIVE",
            "WORLD_VEHICLE_EMPTY",
            "WORLD_VEHICLE_DRIVE_SOLO",
            "WORLD_VEHICLE_BOAT_IDLE_ALAMO",
            "WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN",
            "WORLD_VEHICLE_MILITARY_PLANES_SMALL",
            "WORLD_VEHICLE_MILITARY_PLANES_BIG",
        }
        local SCENARIO_GROUPS = {
            2017590552, -- LSIA planes
            2141866469, -- Sandy Shores planes
            "BLIMP",
            "ALAMO_PLANES",
            "ARMY_HELI",
            "GRAPESEED_PLANES",
            "SANDY_PLANES",
            "ng_planes",
        }
        local SUPPRESSED_MODELS = {
            "SHAMAL",
            "LUXOR",
            "LUXOR2",
            "LAZER",
            "TITAN",
            "CRUSADER",
            "RHINO",
            "AIRTUG",
            "RIPLEY",
            "SUNTRAP",
            "BLIMP",
        }

        Citizen.CreateThread(function()
            while true do

                for _, sctyp in pairs(SCENARIO_TYPES) do
                    SetScenarioTypeEnabled(sctyp, false)
                end

                for _, scgrp in pairs(SCENARIO_GROUPS) do
                    SetScenarioGroupEnabled(scgrp, false)
                end

                for _, model in pairs(SUPPRESSED_MODELS) do
                    SetVehicleModelIsSuppressed(GetHashKey(model), true)
                end

                Wait(5000)
            end
        end)

    end

    AddEventHandler("populationPedCreating", function()
        CancelEvent()
    end)

    Citizen.CreateThread(function()
        -- disables base-game peds spawning
        SetPedNonCreationArea(-16384.0, -16384.0, -16384.0, 16384.0, 16384.0, 16384.0)

        while true do
            Wait(0)
            if IsFiveM then
                SetPedDensityMultiplierThisFrame(0.0)
            end

            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
            
            local pos = LocalPlayer:GetPosition()
            RemoveVehiclesFromGeneratorsInArea(pos.x - 500, pos.y - 500, pos.z - 500, pos.x + 500, pos.y + 500, pos.z + 500);
        end
    end)
end

function World:SetWindSpeed(speed)
    SetWind(tofloat(speed))
end

--[[
    Sets the wind direction.

    This is NOT a heading. It's a FLOAT value from 0.0-7.0. Look at this image:  
    i.imgur.com/FwVpGS6.png
]]
function World:SetWindDirection(dir)
    SetWindDirection(tofloat(dir))
end

function World:GetWindSpeed()
    return GetWindSpeed()
end

-- Returns 3 numbers? Needs testing
function World:GetWindDirection()
    return GetWindDirection()
end

World = World()