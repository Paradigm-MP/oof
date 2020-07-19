Actor = class()
Actor.MAX_HEALTH = 100000000
--[[
    Represents the lowest-level, most re-usable NPC code that can be re-used across
    different gamemodes.
]]

function Actor:ActorInitialize()
    getter_setter(self, "net_id") -- declares Actor:GetNetId() and Actor:SetNetId() for self.net_id
    getter_setter(self, "unique_id") -- declares Actor:GetUniqueId() and Actor:SetUniqueId() for self.unique_id
    getter_setter(self, "local_player_hosted") -- declares Actor:GetLocalPlayerHosted() and Actor:SetLocalPlayerHosted() for self.local_player_hosted
    getter_setter(self, "ready")
    getter_setter(self, "health")
    getter_setter(self, "actor_group_enum")
    getter_setter(self, "agent_profile")
    self:SetHealth(100) -- tentative for initialization until the Actor spawns and we set this to the actual health from base-game at that time

    --self:SetHealth(Actor.MAX_HEALTH)
end

function Actor:ActorHostUpdate()
    --self:AgentHostUpdate()
end

function Actor:InitializeActorFromWaveSurvivalActor()
    self:ActorInitialize()
end

function Actor:GetPedId()
    return NetToPed(self.net_id)
end

function Actor:HasPed()
    return IsEntityAPed(NetToPed(self.net_id))
end

function Actor:LocalPlayerHasControl()
    -- doesnt work ... sort of pretends to work but then the ped natives dont work
    --local control = NetworkHasControlOfNetworkId(self.net_id)
    --return (control == true) or (control == 1)

    local pos = GetEntityCoords(NetToPed(self.net_id))
    return not (pos.x < 0.1 and pos.x > -0.1 and pos.y < 0.1 and pos.y > -0.1 and pos.z < 0.1)
end

function Actor:GetPed()
    return Ped({ped = NetToPed(self.net_id)})
end

function Actor:GetEntity()
    return Entity(NetworkGetEntityFromNetworkId(self.net_id))
end

function Actor:GetEntityId()
    return NetworkGetEntityFromNetworkId(self.net_id)
end

function Actor:GetPosition()
    return GetEntityCoords(NetToPed(self.net_id))
end

-- doesnt work in RedM probably
function Actor:RequestLocalPlayerControl()
    NetworkRequestControlOfNetworkId(self:GetNetId())

    Citizen.CreateThread(function()
        local layover = 0
        while not NetworkHasControlOfNetworkId(self:GetNetId()) do
            layover = layover + 25
            Citizen.Wait(25)
        end

        print("Waited approximately ", layover / 1000, " seconds for Actor Control")
        
        if NetworkHasControlOfNetworkId(self:GetNetId()) then
            -- do something
        end
    end)
end

function Actor:IsStreamed()
    local is_ped = IsEntityAPed(NetToPed(self.net_id))

    return (is_ped == 1) or (is_ped == true)
end

-- consider rewriting, omitting, or changing based on sync logic merging
-- we are currently only calling this & creating the Actor instance on the hosting player
function Actor:Spawn(x, y, z)
    local ped_id = CreatePed(
        ActorModelEnum:GetModelHash(self.model), -- PedHash (modelHash) 
        x + 2, y, z,
        0, -- heading: number
        true, -- isNetwork
        false, -- bool : can be destroyed if it belongs to this calling script
        false,
        false
    )

    local net_id = PedToNet(ped_id)
    self:SetNetId(net_id)
    self:SetLocalPlayerHosted(true)

    SetEntityAsMissionEntity(ped_id)
    SetNetworkIdExistsOnAllMachines(self.net_id, true)
    NetworkDisableProximityMigration(net_id, true)
    NetworkRegisterEntityAsNetworked(ped_id)
    --------- player who spawns runs this code -------

    local unique_id = self:GetUniqueId()
    print("unique id: ", unique_id)

    Network:Send("ai/RegisterActor", {
        actor_unique_id = self:GetUniqueId(),
        net_id = self:GetNetId()
    })

    self:SetHealth(GetEntityHealth(ped_id))
    print("Spawned ped with netId: ", PedToNet(ped_id))
end

function Actor:ApplyPedConfig(config_class)
    local config = config_class()
    config:Apply(self:GetPed())
end

function Actor:ApplyBehavior(behavior_class)
    if not self.behaviors then
        self.behaviors = {}
    end

    local behavior = behavior_class()
    behavior:BehaviorInitialize(self)

    self.behaviors[behavior_class.name] = behavior
end

-- map the behavior event to a function of the same name on the Agent
function Actor:FireBehaviorEvent(event_name, args)
    if self[event_name] then
        self[event_name](self, args)
    end
end
