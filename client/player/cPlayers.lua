cPlayers = class()

function cPlayers:__init()
    self.players_by_unique_id = {}
    self.received_data = false

    Network:Subscribe("api/SyncConnectedPlayers", function(data)
        self:SyncConnectedPlayers(data, not self.received_data)
        self.received_data = true
    end)

    Network:Send("api/RequestApiPlayerData")

    while not self.received_data do
        Wait(10)
    end
end

function cPlayers:__postLoad()
    
end

-- getting all the players from the server
function cPlayers:SyncConnectedPlayers(data, on_init)
    -- print("--- syncing Players ---")
    local local_player_ped_id = LocalPlayer:GetPedId()

    for player_unique_id, sync_data in pairs(data) do
        local player_ped = GetPlayerPed(GetPlayerFromServerId(sync_data.source_id))

        if not self.players_by_unique_id[player_unique_id] then
            self:AddPlayer(sync_data)

            local player = self:GetByUniqueId(sync_data.unique_id)
            if not on_init then
                Events:Fire("PlayerJoined", {player = player})
            end

            -- print("Player Added: ", player)
        else
            self:AddPlayer(sync_data)
        end
    end
    
    -- print("------------------------------------")
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
    -- todo: write new iterator
    return self.players_by_unique_id
end


cPlayers = cPlayers()