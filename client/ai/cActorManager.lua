ActorManager = class()

function ActorManager:__init()
    self.ped_animations = {
        "MOVE_M@DRUNK@VERYDRUNK"
    }

    self.actors = {} -- stores Actor instances per actor_unique_id
    self.local_player_hosted_actors = {} -- actors hosted by LocalPlayer, mapped by actor_unique_id
    
    --self:LoadPedAnimations()

    -- ped models should be unloaded after they are used (bad practice to keep them around apparently)
    -- use this native to 'unload' them: https://runtime.fivem.net/doc/natives/#_0xE532F5D78798DAAB
    Citizen.CreateThread(function() 
        while true do
            Wait(2500)
            --self:ManageHostedPeds()
        end
    end)

    self:ListenForNetworkEvents()
    self:ListenForLocalEvents()
    self:DetectHealthChanges()
    self:CheckForBaseGameActorMigrations() -- never-ending coroutine
    self:DisableBaseGamePeds() -- never-ending coroutine
    self:UpdateHostedActors()
end

function ActorManager:UpdateActors()

    --[[
    Citizen.CreateThread(function()
        while true do
            Wait(50) -- consider scaling this to NPC size
            for actor_unique_id, actor in pairs(self.actors) do
                
            end
        end
    end)
    ]]
end

function ActorManager:IsPedSpawnedActor(ped_id)
    for actor_unique_id, actor in pairs(self.actors) do
        if actor:GetPedId() == ped_id then
            return true
        end
    end

    return false
end

-- currently not using this
function ActorManager:UpdateHostedActors()
    Citizen.CreateThread(function()
        while true do
            Wait(3000) -- consider scaling this to NPC size
            for actor_unique_id, actor in pairs(self.local_player_hosted_actors) do
                if actor.ready then
                    actor:ActorHostUpdate()
                end
            end
        end
    end)
end

function ActorManager:DisableBaseGamePeds()
    

    -- doesnt work in RedM
    AddEventHandler('populationPedCreating', function(x, y, z, model, setters)
        CancelEvent() -- disables all peds
    end)

end

function ActorManager:GetStoredPeds()
    local peds = {}
    for actor_unique_id, actor in pairs(self.local_player_hosted_actors) do
        peds[actor:GetNetId()] = true
    end

    return peds
end

-- check LocalPlayer-hosted actors for migration to another player
function ActorManager:CheckForBaseGameActorMigrations()
    local actor_control_loss_check_delay = 200
    local actor_control_gained_check_delay = 300

    -- checking the local_player_hosted_actors for loss of control
    Citizen.CreateThread(function() 
        while true do
            Wait(actor_control_loss_check_delay)

            local migrations = {}
            for actor_unique_id, actor in pairs(self.local_player_hosted_actors) do
                if not actor:LocalPlayerHasControl() then -- LocalPlayer has lost control of the NPC
                    print("Detected loss of control over spawned NPC")
                    actor:SetLocalPlayerHosted(false)

                    migrations[actor_unique_id] = true
                end
            end

            if count_table(migrations) > 0 then
                for actor_unique_id, data in pairs(migrations) do
                    self.local_player_hosted_actors[actor_unique_id] = nil
                end
            end
        end
    end)

    if 1 == 1 then return end

    local test_timer = Timer()
    -- checking actors not hosted by LocalPlayer to see if we gained control
    Citizen.CreateThread(function() 
        while true do
            Wait(actor_control_gained_check_delay)

            local migrations = {}
            local gained_control = false
            for actor_unique_id, actor in pairs(self.actors) do
                if test_timer:GetSeconds() > 5 then
                    test_timer:Restart()
                    --print("has control: ", actor:CalculateLocalPlayerHasControl())
                    --print("hosting: ", actor:GetLocalPlayerHosted())
                end

                if not actor:GetLocalPlayerHosted() and actor:CalculateLocalPlayerHasControl() == true then -- LocalPlayer has gained control of an actor it did not previously have control of
                    -- CalculateLocalPlayerHasControl sets local_player_hosted to true so we dont need to do SetLocalPlayerHosted here
                   -- print("detected gain control of NPC")
                    migrations[actor_unique_id] = true
                    gained_control = true

                    self.local_player_hosted_actors[actor:GetUniqueId()] = actor
                end
            end

            if gained_control then
                --print("#migrations: ", count_table(migrations))
            end

            if count_table(migrations) > 0 then
                Network:Send("ai/ActorMigrations", {
                    migrations = migrations
                })
                if gained_control then
                    --print("sent migrations to server")
                end

            end
        end
    end)
end

-- requested_control = false
-- jump = false
 function ActorManager:ManageHostedPeds()
     --for actor_unique_id, actor in pairs(self.local_player_hosted_actors) do
     --    actor:BehaviorUpdate()
     --end

     for actor_unique_id, actor in pairs(self.actors) do
         --if not actor:IsLocalPlayerHosting() then
         --    actor:Test()
         --end
         actor:EnsurePedAccess() -- retrieves ped using net id if we havent already
         local net_id = actor:GetNetId() -- this ensures we know which ped it is

         print("----------")
         print("stored net_id: ", net_id)
         print("ped to net: ", PedToNet(actor:GetPed()))
         print("is a ped: ", IsEntityAPed(actor:GetPed()))

         if net_id then
             local actor_ped = NetToPed(net_id)
             actor.ped_id = actor_ped -- this should be done for us in EnsurePedAccess()

             local owner = cPlayers:GetByPlayerId(NetworkGetEntityOwner(actor_ped))
             local has_control = NetworkHasControlOfNetworkId(net_id)

             -- Dev_34 will attempt to take over an NPC from DevBot34
             if 1 == 2 and LocalPlayer:GetName() == "Dev_34" then
                 local has_control = NetworkHasControlOfNetworkId(net_id)
                 print("owner: ", owner)
                 print("LocalPlayer has 'control': ", has_control)

                 actor:LeapForward()

                if not has_control and not requested_control then
                    requested_control = true
                     print("Requesting Control of Entity")

                     -- both natives are having the same behavior
                     --NetworkRequestControlOfEntity(actor_ped)

                     -- run some natives before officially requesting control
                     --SetNetworkIdCanMigrate(net_id, false)
                    
                     Citizen.CreateThread(function() 
                         Wait(1000)
                         NetworkRequestControlOfNetworkId(net_id)
                     end)
                 elseif has_control then
                     print("Localplayer has control over actor_ped according to NetworkHasControlOfNetworkId")
                     --SetNetworkIdCanMigrate(net_id, false)
                    --SetEntityAsMissionEntity(actor.ped_id)
                    --SetNetworkIdExistsOnAllMachines(self.net_id, true)
                     --NetworkRegisterEntityAsNetworked(self.ped_id)

                     actor:EnsurePedAccess()

                     SetNetworkIdCanMigrate(net_id, false)

                     print("actor position: ", actor:GetPosition())
                     actor:LeapForward()
                 end
             else
                 print("owner: ", owner)
                 print("LocalPlayer has 'control': ", has_control)
                 --actor:EnsurePedAccess()
                 --actor:LeapForward()
             end
             --print("NetworkHasControlOfNetworkId: ", NetworkHasControlOfNetworkId(net_id))
         else
             print("Actor has no net id set")
         end
     end
 end

-- TODO: load & unload these when needed
function ActorManager:LoadPedAnimations()
    Citizen.CreateThread(function()
        for index, ped_animation in ipairs(self.ped_animations) do
            -- load animation
            RequestAnimSet(ped_animation)
            while not HasAnimSetLoaded(ped_animation) do
                Citizen.Wait(20)
            end
        end
    end)
end

function ActorManager:ListenForNetworkEvents()
    Network:Subscribe("ai/ActorSpawn", function(data) self:ActorSpawn(data) end)
    Network:Subscribe("ai/ActorSpawned", function(data) self:ActorSpawned(data) end)
    --Network:Subscribe("ai/ActorMigration", function(data) self:ActorMigration(data) end)
end

function ActorManager:ListenForLocalEvents()
    if IsTest then
        Events:Subscribe("Render", function() self:Render() end)
    end
    Events:Subscribe("GameEnd", function(args) self:GameEnd(args) end)
    Events:Subscribe("PlayerNetworkValueChanged", function(args) self:PlayerNetworkValueChanged(args) end)
    Events:Subscribe("NewRound", function(args) self:NewRound(args) end)
end

function ActorManager:GameEnd(args)
    -- the code in this function does not work
    -- we lose control of the actor when we die

    -- Remove Actor Scenario #1: Game ends. clear the actor table
    --Chat:Print("ENTERED GAMEEND CODE")

    local ped_ids = {}
    for actor_unique_id, actor in pairs(self.actors) do
        ped_ids[actor:GetPedId()] = true
    end

    self:EnsureVisibilityOfAllActors()

    Citizen.CreateThread(function()
        for ped_id, _ in pairs(ped_ids) do
            DeletePed(ped_id)
        end
    end)

    local ped
    for actor_unique_id, actor in pairs(self.actors) do
        -- just try to delete everything
        --NetworkRequestControlOfEntity(entity)
        --DeletePed(actor:GetPedId())
        --Chat:Print("TRIED TO DELETE PED")
    end

    self.actors = {}
end

function ActorManager:NewRound(args)
    Citizen.CreateThread(function()
        self:EnsureVisibilityOfAllActors()

        local ped
        for actor_unique_id, actor in pairs(self.actors) do
            -- just try to delete everything
            ped = actor:GetPed()
            ped:Delete()
        end

        self.actors = {}
    end)
end

function ActorManager:EnsureVisibilityOfAllActors()
    -- try to stop the invisible enemy
    for actor_unique_id, actor in pairs(self.actors) do
        -- use the visibility native 
        Citizen.InvokeNative(0x283978A15512B2FE, actor:GetPedId(), true)
    end
end

function ActorManager:DetectHealthChanges()
    Citizen.CreateThread(function()
        local current_health, stored_health, damage
        local actor_ped_id

        while true do
            Wait(1)
            
            for actor_unique_id, actor in pairs(self.actors) do
                --print(actor:GetReady(), actor:LocalPlayerHasControl(), GetEntityHealth(actor:GetPedId()))
                if actor:GetReady() and actor:LocalPlayerHasControl() then
                    actor_ped_id = actor:GetPedId()
                    stored_health = actor:GetHealth()
                    current_health = GetEntityHealth(actor:GetEntityId())

                    --print("current_health: ", current_health)
                    --print(stored_health, " ", current_health)

                    if stored_health ~= current_health then
                        actor:SetHealth(current_health)
                        damage = stored_health - current_health

                        --Chat:Print("Detected damage of: " .. tostring(damage))
                        --Chat:Print("Current Health: " .. tostring(current_health))

                        if current_health == 0 and IsEntityDead(actor:GetPedId()) then -- if health == 0 then they are dead
                            -- GetPedSourceOfDeath was tested with LF and worked (host can detect actual killer)
                            local killer_entity = GetPedSourceOfDeath(actor_ped_id)
                            local killer_found = false
                            local actor_pos = actor:GetPed():GetPosition()
                            local actor_pos_serialized = {x = actor_pos.x, y = actor_pos.y, z = actor_pos.z}
                        
                            local id = actor:GetPedId()
                            SetEntityAsMissionEntity(id, false, false) -- VITAL

                            Citizen.CreateThread(function()
                                Citizen.Wait(5000)
                                local pos = GetEntityCoords(id)
                                Object({
                                    model = "p_door12x",
                                    position = pos - vector3(0, 0, 1),
                                    isNetwork = true,
                                    kinematic = true, -- VITAL
                                    callback = function(obj)
                                        obj:Destroy() 
                                    end
                                })
                            end)

                            for id, player in pairs(cPlayers:GetPlayers()) do
                                if player:GetPedId() == killer_entity then
                                    --Chat:Print(tostring(player) .. " killed NPC")
                                    killer_found = true

                                    Network:Send("ai/ActorKilled", {
                                        killer_type = "Player", -- best practice would be enum
                                        killer_unique_id = player:GetUniqueId(),
                                        actor_position = actor_pos_serialized,
                                        dead_actor_unique_id = actor:GetUniqueId()
                                    })

                                    Events:Fire("ai/HostedActorKilled", {
                                        dead_actor = actor,
                                        killer_type = "Player",
                                        killer = player,
                                        actor_position = actor_pos_serialized
                                    })

                                    self:HostedActorKilled(actor)
                                end
                            end


                            if not killer_found and killer_entity ~= 0 then -- means killer is not a player
                                print("Registered Actor and killer is not Player")
                                local killer_actor
                                for actor_unique_id_iter, actor_iter in pairs(self.actors) do
                                    if actor_iter:GetPedId() == killer_entity then
                                        killer_actor = actor_iter

                                        Network:Send("ai/ActorKilled", {
                                            killer_type = "Actor",
                                            killer_unique_id = killer_actor:GetUniqueId(),
                                            dead_actor_unique_id = actor:GetUniqueId(),
                                            actor_position = actor_pos_serialized
                                        })
                                        break
                                    end
                                end

                                -- TODO: find out which actor killed the other actor
                                Events:Fire("ai/HostedActorKilled", {
                                    dead_actor = actor,
                                    killer_type = "Actor",
                                    actor_position = actor_pos_serialized,
                                    killer = killer_actor -- could be nil
                                })

                                self:HostedActorKilled(actor)

                                --local ped_id = actor:GetPedId()
                                --.CreateThread(function(ped_id)
                                --    while true do
                                --        Wait(1000)
                                --        print("'Dead' Actor's health: ", GetEntityHealth(ped_id))
                                --    end
                                --)
                            end
                        end
                    end
                end
            end
        end
    end)
end

function ActorManager:HostedActorKilled(actor)
    actor:GetPed():SoftRemove()
end

function ActorManager:Render()
    --local actors = self:GetValidActors()
    --local actor_position
    --for actor_unique_id, actor in pairs(actors) do
        --actor_position = actor:GetPosition()
        --Render:DrawText(Render:WorldToScreen(actor_position + vector3(0, 0, 1.00)), "GetEntityHealth(): " .. tostring(GetEntityHealth(actor:GetEntityId())), Colors.Tomato, 1, 0.5)
    --end

    --for actor_unique_id, actor in pairs(self.actors) do
        
        --if actor:HasPed() then
            --if IsEntityAPed(actor:GetPedId()) then
            --local actor_position = actor:GetPosition()
            --Render:DrawText(Render:WorldToScreen(actor_position), tostring(actor_position), Colors.LawnGreen, 1, 1)
            --Render:DrawText(Render:WorldToScreen(actor_position + vector3(0, d0, .5)), "actor:IsLocalPlayerHosting(false): " .. tostring(actor:IsLocalPlayerHosting(false)), Colors.LawnGreen, 1, 1)
            --Render:DrawText(Render:WorldToScreen(actor_position + vector3(0, 0, .5)), "actor:IsLocalPlayerHosting(): " .. tostring(actor:IsLocalPlayerHosting()), Colors.LawnGreen, 1, 1)
            --Render:DrawText(Render:WorldToScreen(actor_position + vector3(0, 0, 0.5)), "NetworkGetEntityOwner(): " .. tostring(NetworkGetEntityOwner(actor:GetPedId2())), Colors.LawnGreen, 0.5, 1)
            --Render:DrawText(Render:WorldToScreen(actor_position + vector3(0, 0, 1.00)), "GetEntityHealth(): " .. tostring(GetEntityHealth(actor:GetEntityId())), Colors.Tomato, 1, 1)
            
            --Render:DrawText(Render:WorldToScreen(actor_position + vector3(0, 0, 0.35)), "IM HOSTING THIS ONE (" .. tostring(actor:GetPedId()) .. ")", Colors.LawnGreen, 0.5, 1)
        --end

        --local actor_position = actor:GetPosition()
        --if actor:GetReady() then
            --Render:DrawText(Render:WorldToScreen(actor_position + vector3(0, 0, 0.75)), "IsDead: (" .. tostring(IsEntityDead(actor:GetPedId())) .. ")", Colors.LawnGreen, 0.5, 1)
            --Render:DrawText(Render:WorldToScreen(actor_position + vector3(0, 0, 1.25)), "Health: (" .. tostring(GetEntityHealth(actor:GetPedId())) .. ")", Colors.LawnGreen, 0.5, 1)
            --Render:DrawText(Render:WorldToScreen(actor_position + vector3(0, 0, 1.85)), "HasControl: (" .. tostring(actor:LocalPlayerHasControl()) .. ")", Colors.LawnGreen, 0.5, 1)
            --Render:DrawText(Render:WorldToScreen(actor_position + vector3(0, 0, 2.25)), "HasPed: (" .. tostring(actor:HasPed()) .. ")", Colors.LawnGreen, 0.5, 1)
        --end
        --Render:DrawText(Render:WorldToScreen(actor_position + vector3(0, 0, 0.75)), "HasControl: (" .. tostring(NetworkRequestControlOfNetworkId(actor.net_id)) .. ")", Colors.LawnGreen, 0.5, 1)
    --end
end

-- only the player who is spawning the Actor executes this particular function
function ActorManager:ActorSpawn(data)
    local player = cPlayers:GetByUniqueId(LocalPlayer:GetUniqueId())

    if not player then print("player is nil in ActorSpawn") end

    local agent_profile_class = AgentProfileEnum:GetClassFromEnum(data.agent_profile_enum)
    local actor = agent_profile_class(data.actor_data)
    actor:SetUniqueId(data.actor_unique_id)
    actor:Spawn(data.x, data.y, data.z)

    self.local_player_hosted_actors[data.actor_unique_id] = actor
    print("LocalPlayer is now hosting an Actor with actor_unique_id: ", data.actor_unique_id)

    self.actors[data.actor_unique_id] = actor
end

-- all other players other than the hosting player run this function to register the actor
function ActorManager:ActorSpawned(data)
    local hosting_player = cPlayers:GetByUniqueId(data.host)

    if self.actors[data.actor_unique_id] then
        self.actors[data.actor_unique_id]:SetActorGroupEnum(data.actor_group)
        self.actors[data.actor_unique_id]:SetAgentProfile(data.agent_profile_enum)
    end

    -- do not store the actor if this client spawned it
    if LocalPlayer:IsPlayer(hosting_player) then
        Events:Fire("ActorSpawned", {
            actor = self.actors[data.actor_unique_id]
        })
        return
    end

    if not hosting_player then print("hosting_player is nil in ActorSpawned") end

    print("Hosting player: ", hosting_player)

    local agent_profile_class = AgentProfileEnum:GetClassFromEnum(data.agent_profile_enum)
    local actor = agent_profile_class()
    actor:SetUniqueId(data.actor_unique_id)
    actor:SetActorGroupEnum(data.actor_group)
    actor:SetAgentProfile(data.agent_profile_enum)
    actor:SetNetId(data.net_id)
    actor:SetLocalPlayerHosted(false)

    self.actors[data.actor_unique_id] = actor

    Events:Fire("ActorSpawned", {
        actor = actor
    })
end

function ActorManager:FindPedsInGame()
    local peds = {}
    local handle, ped = FindFirstPed()
    local finished = false -- FindNextPed will turn the first variable to false when it fails to find another ped in the index

    repeat
        if not IsEntityDead(ped) then
            table.insert(peds, ped) -- inserts a number (i think the client-side id for this ped)
        end
        ped, finished = FindNextPed(handle) -- first param returns true while entities are found
    until not finished
    EndFindPed(handle)

    return peds
end

function ActorManager:GetActorsHostedByLocalPlayer()
    print("error - dont use this function it's broken (ithink)?")
    return self.local_player_hosted_actors
end

function ActorManager:PlayerNetworkValueChanged(args)
    if IsTest then
        print("Network Value {", args.name, "} changed to {", args.val, "} for {", args.player, "}")
    end
    
    if args.name == "Downed" and args.val == true then
        -- some Player was Downed (could be LocalPlayer)
        Events:Fire("PlayerDowned", {
            player = args.player,
            is_localplayer = LocalPlayer:IsPlayer(args.player)
        })
    end
end

ActorManager = ActorManager()