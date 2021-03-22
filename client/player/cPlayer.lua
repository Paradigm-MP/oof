-- a Player instance represents a single player in the game
Player = class(ValueStorage)

function Player:__init(player_id, steam_id, server_id, unique_id)
    self.player_id = player_id
    self.steam_id = steam_id
    self.server_id = server_id
    self.unique_id = unique_id
    self.__is_player_instance = true
    self.ped = Ped({ped = GetPlayerPed(self.player_id)})

    self:InitializeValueStorage(self)
    self:SetValueStorageNetworkId(self.server_id)
end

function Player:SetControl(enabled)
    SetPlayerControl(self.player_id, enabled, false)
end

--[[
    Changes the model of the player.
    Warning: this function is not a wrapped in a thread

    WARNING: THIS WILL DESTROY THE CURRENT PED AND CREATE A NEW
    ONE FOR THIS PLAYER.
]]
function Player:SetModel(model, cb)
    local hashkey = GetHashKey(model)
    LoadModel(hashkey, function()
        -- change the player model
        SetPlayerModel(self.player_id, hashkey)

        -- release the player model
        SetModelAsNoLongerNeeded(hashkey)

        -- RDR3 player model bits
        if N_0x283978a15512b2fe then
            N_0x283978a15512b2fe(PlayerPedId(), true)
        end
        cb()
    end)
end

--[[
    Updates the Ped class so that the Ped is still valid for this player.
    Useful for respawning or changing model.
]]
function Player:GetPed()
    local player_ped_id = GetPlayerPed(self.player_id)
    if self.ped:GetEntityId() ~= player_ped_id then
        self.ped:UpdatePedId(player_ped_id)
    end

    return self.ped
end

function Player:GetEntity()
    return self:GetPed()
end

function Player:GetEntityId()
    return GetPlayerPed(self.player_id)
end

function Player:GetPedId()
    return GetPlayerPed(self.player_id)
end

--[[
    Freezes the player, including movement controls.

    Same as original scripts.
]]
function Player:Freeze(freeze)
    self:SetControl(not freeze)

    local ped = self:GetPed()
    local entity = Entity(ped:GetPedId())

    if not freeze then
        if not entity:IsVisible() then
            entity:SetVisible(true)
        end

        if not ped:InVehicle() then
            entity:ToggleCollision(true)
        end

        entity:SetKinematic(false)
        entity:SetInvincible(false)
    else
        if entity:IsVisible() then
            entity:SetVisible(false)
        end

        entity:ToggleCollision(false)
        entity:SetKinematic(true)
        entity:SetInvincible(true)

        if not ped:IsFatallyInjured() then
            ClearPedTasksImmediately(ped.ped_id)
        end
    end
end

function Player:SetWeaponDamageModifier(modifier)
    SetPlayerWeaponDamageModifier(self:GetPlayerId(), tofloat(modifier))
end

function Player:SetMeleeWeaponDamageModifier(modifier)
    SetPlayerMeleeWeaponDamageModifier(self:GetPlayerId(), tofloat(modifier))
end

function Player:SetRunSprintMultiplier(multiplier)
    SetRunSprintMultiplierForPlayer(self:GetPlayerId(), tofloat(multiplier))
end

function Player:ResetStamina()
    ResetPlayerStamina(self.player_id)
end

function Player:DisableFiring(disabled)
    self.firing_disabled = disabled

    Citizen.CreateThread(function()
        while self.firing_disabled do
            DisablePlayerFiring(self.player_id, true)
            Wait(1)
        end
    end)

end

function Player:GetPosition()
    return self:GetPed():GetPosition()
end

function Player:SetName(name)
    self.name = name
end

function Player:GetName()
    return self.name
end

function Player:GetId()
    return self.server_id
end

function Player:GetPlayerId()
    return self.player_id
end

function Player:GetSteamId()
    return self.steam_id
end

function Player:GetUniqueId()
    return self.unique_id
end

function Player:Disconnected()
    
end



function Player:tostring()
    return "Player (" .. self.name .. ")"
end