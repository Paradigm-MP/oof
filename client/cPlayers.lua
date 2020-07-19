cPlayers = load_first_class()

function cPlayers:__loadFirst()
    self.players_by_unique_id = {}

    -- Network is an immediate_class, so we can use it in __loadFirst
    Network:Subscribe("api/SyncConnectedPlayers", function(data)
        if not self.__loadFirstCompleted then
            self.player_sync_data = data
            self.__loadFirstCompleted = true
        else
            self:SyncConnectedPlayers(data)
        end
    end)

    Network:Send("api/RequestApiPlayerData")
end

function cPlayers:__init()
    self.players_by_unique_id = {}

    -- create & store Player instances out of the data that __loadFirst retrieved
    self:SyncConnectedPlayers(self.player_sync_data, true)
end

function cPlayers:__postLoad()
    
end

-- getting all the players from the server
function cPlayers:SyncConnectedPlayers(data, on_init)
    print("--- entered SyncConnectedPlayers ---")
    local local_player_ped_id = LocalPlayer:GetPedId()

    for player_unique_id, sync_data in pairs(data) do
        local player_ped = GetPlayerPed(GetPlayerFromServerId(sync_data.source_id))

        --print("sync_data: ")
        --for k, v in pairs(sync_data) do
        --    print(k, " | ", v)
        --end

        if player_ped == local_player_ped_id then
            LocalPlayer:SetUniqueId(sync_data.unique_id)
            LocalPlayer:SetName(sync_data.name)
        end

        if not self.players_by_unique_id[player_unique_id] then
            self:AddPlayer(sync_data)

            local player = self:GetByUniqueId(sync_data.unique_id)
            -- TODO: add a __postLoad so we can fire this event when all the code is ran
            if not on_init then
                Events:Fire("PlayerJoined", {player = player})
            end

            print("new Player Added: ", player)
        else
            self:AddPlayer(sync_data)
        end
    end
    
    print("------------------------------------")
end

function cPlayers:GetLocalPlayer()
    for player_unique_id, player in pairs(self.players_by_unique_id) do
        if LocalPlayer:IsPlayer(player) then
            return player
        end
    end
end

function cPlayers:GetNearestPlayer(position)
    local closest_player
    local closest_distance = 99999

    for player_unique_id, player in pairs(self.players_by_unique_id) do
        local distance =  #(position - player:GetPosition())

        if distance < closest_distance then
            closest_distance = distance
            closest_player = player
        end
        --print("distance: ", distance)
    end

    return closest_player, closest_distance
end

function cPlayers:AddPlayer(sync_data)
    local player = Player(GetPlayerFromServerId(sync_data.source_id), 
        sync_data.steam_id, sync_data.source_id, sync_data.unique_id)
    player:SetName(sync_data.name)

    for name, value in pairs(sync_data.network_values) do
        --Chat:Print("Set net val on player")
        player:SetValue(name, value)
    end

    self.players_by_unique_id[player:GetUniqueId()] = player
end

function cPlayers:RemovePlayer(player_unique_id)
    self.players_by_unique_id[player_unique_id] = nil
end

function cPlayers:GetByUniqueId(player_unique_id)
    return self.players_by_unique_id[player_unique_id]
end

function cPlayers:GetByPlayerId(id)
    for player_unique_id, player in pairs(self.players_by_unique_id) do
        if player:GetPlayerId() == id then
            return player
        end
    end
end

function cPlayers:GetByServerId(server_id)
    for player_unique_id, player in pairs(self.players_by_unique_id) do
        if player:GetId() == server_id then
            return player
        end
    end
end

function cPlayers:GetNumPlayers()
    return count_table(self.players_by_unique_id)
end

function cPlayers:GetPlayers()
    return self.players_by_unique_id
end


cPlayers = cPlayers()