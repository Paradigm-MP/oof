World = class()

function World:__init()
    self.timestep_enabled = false
    self.time = {hours = 12, minutes = 0, seconds = 0}
    getter_setter(self, "weather")
    self:SetWorldWeather("SUNNY")
    self.timescale = 1
    self.blackout = false

    Events:Subscribe("PlayerJoined", self, self.PlayerJoined)
end

--[[
    Keep track of time here so we can sync accurate time to new clients
]]
function World:TimeStep()

    Citizen.CreateThread(function()
    
        while self.timestep_enabled do
            Wait(1000)
            self.time.seconds = self.time.seconds + 30
            if self.time.seconds == 60 then
                self.time.seconds = 0
                self.time.minutes = self.time.minutes + 1
            end

            if self.time.minutes == 60 then
                self.time.minutes = 0
                self.time.hours = self.time.hours + 1
            end

            if self.time.hours == 24 then
                self.time.hours = 0
            end

        end
    
    end)

end

function World:PlayerJoined(args)

    Network:Send("API/World/InitialSync", args.player:GetId(), {
        timestep_enabled = self:GetTimestepEnabled(),
        time = self:GetTime(),
        blackout = self:GetBlackout(),
        weather = self:GetWeather()
    })
end

function World:SetTime(hours, minutes, seconds)
    --print("Setting time to {", hours, "}, {", minutes, "}, {", seconds, "}")
    self.time = {hours = hours, minutes = minutes, seconds = seconds}
    Network:Broadcast("API/World/SetTime", {time = self.time})
end

function World:SetTimestepEnabled(enabled)
    self.timestep_enabled = enabled
    self:TimeStep()
    Network:Send("API/World/SetTimestepEnabled", -1, {enabled = self:GetTimestepEnabled()})
end

function World:SetTimeScale(scale)
    self.timescale = scale
    Network:Send("API/World/SetTimeScale", -1, {scale = self:GetTimeScale()})
end

function World:SetBlackout(blackout)
    self.blackout = blackout
    Network:Send("API/World/SetBlackout", -1, {blackout = self:GetBlackout()})
end

function World:SetWorldWeather(weather)
    self:SetWeather(weather)
    Network:Broadcast("API/World/SetWeather", {weather = self:GetWeather()})
end

function World:GetTimestepEnabled()
    return self.timestep_enabled
end

function World:GetTimeScale()
    return self.timescale
end

function World:GetTime()
    return self.time
end

function World:GetBlackout()
    return self.blackout
end

World = World()