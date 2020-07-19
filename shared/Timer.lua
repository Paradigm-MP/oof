Timer = class()

function Timer:__init()
    self.timer = GetGameTimer()
end

-- No microseconds, because who the heck uses those anyway

function Timer:GetMilliseconds()
    return GetGameTimer() - self.timer
end

function Timer:GetSeconds()
    return self:GetMilliseconds() / 1000
end

function Timer:GetMinutes()
    return self:GetSeconds() / 60
end

function Timer:GetHours()
    return self:GetMinutes() / 60
end

function Timer:Restart()
    self.timer = GetGameTimer()
end