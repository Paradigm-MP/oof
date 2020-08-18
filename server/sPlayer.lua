-- a Player instance represents a single player in the game
Player = class(ValueStorage)

function Player:__init(player_id, ids)
    self.__type = "Player"
    self.player_id = tonumber(player_id)
    self.ids = ids -- steam, discord, license, live (xbox live), fivem, ip
    self.name = GetPlayerName(player_id)
    self.ep = GetPlayerEP(player_id)
    self.__is_player_instance = true

    math.randomseed(self:GetUniqueId())
    self.color = Color:FromHSV(
        math.random(),
        0.7 + (math.random() * 0.3),
        0.8 + (math.random() * 0.2)
    )

    self:InitializeValueStorage(self)
    self:SetValueStorageNetworkId(self.player_id)
end

function Player:IsValid()
    return GetPlayerEP(self.player_id) ~= nil
end

function Player:Kick(reason)
    DropPlayer(self.player_id, reason or "You have been kicked from the server")
end

--[[
    Returns player endpoint
]]
function Player:GetEP()
    return self.ep
end

function Player:GetIP()
    return self.ids.ip
end

function Player:GetXBoxLiveId()
    return self.ids.live
end

function Player:GetDiscordId()
    return self.ids.discord
end

function Player:GetLicense()
    return self.ids.license
end

function Player:GetName()
    return self.name
end

function Player:GetId()
    return self.player_id
end

function Player:GetUniqueId()
    return self.ids.license
end

function Player:GetSteamId()
    return self.ids.steam
end

function Player:GetColor()
    return self.color
end

function Player:Disconnected()
    -- handle disconnect stuff here
    -- do not delete data yet as this instance is being passed with Events:Fire("PlayerQuit")
end

function Player:StoreValue(key, value)
    assert(type(key) == "string", "key must be a string")
    KeyValueStore:Set(self:GetUniqueId() .. key, value)
end

function Player:GetStoredValue(key, callback)
    assert(type(key) == "string", "key must be a string")
    KeyValueStore:Get(self:GetUniqueId() .. key, function(value)
        callback(value)
    end)
end

function Player:tostring()
    return "Player (" .. self.name .. ")"
end