-- a Player instance represents a single player in the game
Player = class(ValueStorage)

function Player:__init(player_id, steam_id, server_id, unique_id)
    self.player_id = player_id
    self.steam_id = steam_id
    self.server_id = server_id
    self.unique_id = unique_id
    self.__is_player_instance = true
    self.__type = "Player"
    -- TODO: implemetation point in 1.3
    self.group = CreateGroup(self.server_id)
    --print("Player group id: ", self.group)

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
    Recreates the Ped class so that the Ped is still valid for this player.
    Useful for respawning or changing model.
]]
function Player:GetPed()
    return Ped({ped = GetPlayerPed(self.player_id)})
end

function Player:GetEntity()
    return Entity(GetPlayerPed(self.player_id))
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