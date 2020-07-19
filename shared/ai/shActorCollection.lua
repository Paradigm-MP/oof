ActorCollection = class()

function ActorCollection:__init()
    self.actors = {} -- maps unique_actor_id to Actor instance
    self.actors_count = 0
end

function ActorCollection:SetHost(player)
    self.host = player
end

function ActorCollection:GetHost()
    return self.host
end

function ActorCollection:AddActor(actor)
    local unique_actor_id = actor:GetUniqueId()
    
    self.actors[unique_actor_id] = actor
    self.actors_count = self.actors_count + 1
end

function ActorCollection:RemoveActor(actor_unique_id)
    self.actors[actor_unique_id] = nil
    self.actors_count = self.actors_count + 1
end

function ActorCollection:GetActorByUniqueActorId(unique_actor_id)
    return self.actors[unique_actor_id]
end

function ActorCollection:GetActors() -- key: actor_unique_id, value: Actor instance
    return self.actors
end

function ActorCollection:GetCount()
    return self.actors_count
end



function ActorCollection:tostring()
    return "ActorCollection (" .. tostring(self:GetCount()) .. ")"
end