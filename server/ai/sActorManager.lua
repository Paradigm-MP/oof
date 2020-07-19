ActorManager = class()
-- Keeps track of all the Actors in the server on a per-player basis.
-- We do it on a per-player basis because we are using an NPC "hosting" system
-- in which one client makes the decisions for & controls a particular Actor

function ActorManager:__init()
    self.actors = {} -- maps player_unique_id to ActorCollection
    self.actors_by_unique_actor_id = {} -- maps actor_unique_id to Actor instance
    self.id_pool = IdPool()
    
    Events:Subscribe("PlayerQuit", function(data) self:PlayerQuit(data) end)
    Events:Subscribe("GameEnd", function(args) self:GameEnd(args) end)

    self:ListenForNetworkEvents()
end

function ActorManager:ListenForNetworkEvents()
    Network:Subscribe("ai/RegisterActor", function(source, data) self:RegisterActor(source, data) end)
    --Network:Subscribe("ai/ActorMigrations", function(source, data) self:ActorMigrations(source, data) end)
    Network:Subscribe("ai/ActorKilled", function(args) self:ActorKilled(args) end)
end

-- tell the player to spawn the actor, the player sends the net_id back, then send the net_id to all the other clients
-- player arg is the player who is hosting this actor
-- we sync this with every player so that every player has the collection of actors
-- however, we are not going to sync every data member of the actor all the time
function ActorManager:Spawn(player, agent_profile_enum, actor_group_enum, actor_data)
    local agent_profile_class = AgentProfileEnum:GetClassFromEnum(agent_profile_enum)
    local actor = agent_profile_class()

    actor:SetHost(player)
    actor:UpdateNetworkPosition(actor_data.spawn_position)
    actor:SetAgentProfile(agent_profile_enum)

    local actor_unique_id = self.id_pool:GetNextId()
    self.actors_by_unique_actor_id[actor_unique_id] = actor

    actor:SetUniqueId(actor_unique_id)
    actor:SetHost(player)
    actor:SetActorGroup(actor_group_enum)

    local unique_id = player:GetUniqueId()
    if not self.actors[unique_id] then
        --print("Created new actor collection")
        local actor_collection = ActorCollection()
        actor_collection:AddActor(actor)
        actor_collection:SetHost(player)

        self.actors[unique_id] = actor_collection
        --print("actor collection host: " .. tostring(actor_collection:GetHost():GetName()))
    else
        --print("added to old player collection")
        local actor_collection = self.actors[unique_id]
        actor_collection:AddActor(actor)
        --print("actor collection host: " .. tostring(actor_collection:GetHost():GetName()))
    end

    --print("player unique id: " .. tostring(player:GetUniqueId()))
    --print("new actor host: " .. tostring(actor:GetHost():GetName()))

    -- tell the player to spawn the actor, the player sends the net_id back, then send the net_id to all the other clients
    Network:Send("ai/ActorSpawn", player:GetId(), {
        x = actor_data.spawn_position.x, y = actor_data.spawn_position.y, z = actor_data.spawn_position.z, 
        agent_profile_enum = agent_profile_enum,
        actor_group = actor_group_enum,
        actor_unique_id = actor_unique_id,
        actor_data = actor_data
    })
end

function ActorManager:GetActorByUniqueActorId(unique_actor_id)
    return self.actors_by_unique_actor_id[unique_actor_id]
end

function ActorManager:IsPlayerStored(player_unique_id)
    if self.actors[player_unique_id] then
        return true
    else
        return false
    end
end

function ActorManager:GetActorCollection(player_unique_id)
    assert(self:IsPlayerStored(player_unique_id), "sActorManager Error: tried to GetActorCollection but an ActorCollection does not exist for this player")

    local actor_collection_instance = self.actors[player_unique_id]
    return actor_collection_instance
end

-- create the ActorCollection entry for the player_unique_id if it doesn't already exist
function ActorManager:EnsureActorCollection(player_unique_id)
    if not self:IsPlayerStored(player_unique_id) then
        local actor_collection = ActorCollection()
        actor_collection:SetHost(player_unique_id)
        
        self.actors[player_unique_id] = actor_collection
    end
end

-- returns empty table if the player isn't hosting any actors
function ActorManager:GetActorsByHostedPlayer(player_unique_id)
    local actor_collection_instance = self.actors[player_unique_id]

    if actor_collection_instance then
        local actors = actor_collection_instance:GetActors()
        
        if actors:GetCount() > 0 then
            return actors
        else
            return {}
        end
    else
        return {}
    end
end

function ActorManager:PlayerQuit(data) -- data.player: Player, data.reason: string
    print("Entered ActorManager:PlayerQuit")

    local player_unique_id = data.player:GetUniqueId()
    if self:IsPlayerStored(player_unique_id) then
        local actor_collection = self:GetActorCollection(player_unique_id)
        self.actors[player_unique_id] = nil -- clear out the entry for this player cuz they're gone
    end
end

function ActorManager:GameEnd(args)
    -- the clients will clear the actor table when the "game/sync/end" event reaches them

    -- the serverside should clear the actors table too
    -- garbage collection *should* eventually get rid of the instances in memory
    print("Cleared the actors table")
    self.actors = {}
    self.actors_by_unique_actor_id = {}
end

-- args.killer_type: "Player" or "Actor"
-- args.killer_unique_id
-- args.actor_unique_id
function ActorManager:ActorKilled(args)
    local dead_actor = ActorManager:GetActorByUniqueActorId(args.dead_actor_unique_id)
    if dead_actor then
        local hosting_player = dead_actor:GetHost()
        local hosting_player_unique_id = hosting_player:GetUniqueId()
        local killer
        if args.killer_type == "Actor" then
            killer = ActorManager:GetActorByUniqueActorId(args.killer_unique_id)
        elseif args.killer_type == "Player" then
            killer = sPlayers:GetByUniqueId(args.killer_unique_id)
        end

        if hosting_player then
            ActorManager:EnsureActorCollection(hosting_player_unique_id)
            local hosting_player_actor_collection = self:GetActorCollection(hosting_player:GetUniqueId())
            hosting_player_actor_collection:RemoveActor(dead_actor:GetUniqueId())
        end

        Events:Fire("ActorKilled", {
            actor = dead_actor,
            actor_position = vector3(args.actor_position.x, args.actor_position.y, args.actor_position.z),
            killer = killer, -- could be nil
            killer_type = args.killer_type
        })

        print("killer: ", killer)
        print("dead_actor: ", dead_actor)

        if killer then
            --Chat:Broadcast({
            --    text = tostring(killer) .. " killed " .. tostring(dead_actor)
            --})
        end

        self.actors[dead_actor:GetUniqueId()] = nil
    else
        print("ActorKilled but not found in self.actors")
    end
    
end

-- client tells server they made a ped and tells server the net_id
function ActorManager:RegisterActor(data)
    local player = sPlayers:GetById(source)
    local actor = self.actors_by_unique_actor_id[data.actor_unique_id]

    --print("player: ", player)
   -- print("Actor: ", actor)

    if actor then -- the server authorizes actors, so we should already have it stored
        actor:SetNetId(data.net_id)

        -- create the Actor data on all the other clients
        Network:Send("ai/ActorSpawned", -1, {
            actor_unique_id = actor:GetUniqueId(),
            agent_profile_enum = actor:GetAgentProfile(),
            actor_group = actor:GetActorGroup(),
            net_id = data.net_id,
            host = player:GetUniqueId()
        })
    else
        print("Error in sActorManager: actor with unique id sent from client is not being stored")
    end
end

-- not applicable to RedM (no migrations)
-- player who sent request has gained base-game control of 1 or more actors
function ActorManager:ActorMigrations(data)
    print("ENTERED ACTOR MIGRATIONS")

    local source_player = sPlayers:GetById(source)
    local source_player_unique_id = source_player:GetUniqueId()
    self:EnsureActorCollection(source_player_unique_id)
    local source_player_actor_collection = self:GetActorCollection(source_player_unique_id)

    local migrated_actors = {}
    for actor_unique_id, actor_migration in pairs(data.migrations) do
        local actor = self.actors_by_unique_actor_id[actor_unique_id]
        local old_host = actor:GetHost()
        local old_host_unique_id = old_host:GetUniqueId()
        local old_host_actor_collection = self:GetActorCollection(old_host_unique_id)

        if source_player_unique_id ~= old_host_unique_id then
            -- remove the actor from old host actor collection
            old_host_actor_collection:RemoveActor(actor_unique_id)

            -- add the actor to new host actor collection & set new host on Actor
            source_player_actor_collection:AddActor(actor)
            actor:SetHost(source_player)

            print("migrating actor: ", actor, " from ", old_host, " to ", source_player)
            table.insert(migrated_actors, {
                actor_unique_id = actor_unique_id,
                net_id = actor:GetNetId()
            })
        else
            print("false migration attempted from: ", old_host, " to ", source_player)
        end
    end
end

ActorManager = ActorManager()