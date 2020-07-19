Actor = class()

function Actor:ActorInitialize()
    getter_setter(self, "net_id") -- declares Actor:GetNetId() and Actor:SetNetId()
    getter_setter(self, "unique_id") -- declares Actor:GetUniqueId() and Actor:SetUniqueId()
    getter_setter(self, "actor_group") -- declares Actor:GetActorGroup() and Actor:SetActorGroup()
    getter_setter(self, "agent_profile") -- declares Actor:GetAgentProfile() and Actor:SetAgentProfile()
end

-- since other classes will inherit from this class, we will not use the automatic __init constructor
-- we can't do this because the derived class constructor will override with its own __init function
-- therefore we will specify a constructor for each derived class, or we can re-use them among derived classes
function Actor:InitializeActorFromWaveSurvivalActor()
    self:ActorInitialize()
end

function Actor:SetHost(player)
    self.host = player -- a Player instance
end

function Actor:GetHost()
    return self.host
end

-- doesnt teleport the Actor or anything. this updates the last known position of the actor
function Actor:UpdateNetworkPosition(position)
    self.network_position = position
end

function Actor:tostring()
    return self.profile_name and self.profile_name or "Actor" .. tostring(self.unique_id)
end