sPlayers = class()

function sPlayers:__init()
    self.players_by_unique_id = {}

    for _, player_id in pairs(GetPlayers()) do
        self:AddPlayer(player_id, true)
    end
end

-- !! this function must be __loadFirst compatible. ask Dev_34 if confused
function sPlayers:AddPlayer(source, already_connected)
    if self:GetById(source) then return end

    local ids = self:GetPlayerIdentifiers(source)

    -- Getting license failed
    if not ids.license then
        DropPlayer(source, "Could not retrieve license id")
        return
    end

    local player = Player(tonumber(source), ids) -- Player is an immediate_class
    local player_unique_id = player:GetUniqueId()

    if self.players_by_unique_id[player_unique_id] then
        DropPlayer(source, "A player with your unique id already exists on the server")
        return
    end

    self.players_by_unique_id[player_unique_id] = player

    if not already_connected then
        print(string.format("%s%s (%i | %s | %s) joined the server.%s", 
            Colors.Console.Yellow, player:GetName(), player:GetId(), player:GetUniqueId(), player:GetIP(), Colors.Console.Default))
        Events:Fire("PlayerJoined", {player = player})
    end
end

function sPlayers:RemovePlayer(player_unique_id)
    assert(self.players_by_unique_id[player_unique_id] ~= nil, "sPlayers:RemovePlayer tried to remove player that wasn't stored")

    self.players_by_unique_id[player_unique_id] = nil
end

function sPlayers:GetPlayerSyncData(player)
    return {
        source_id = player:GetId(), 
        steam_id = player:GetSteamId(), 
        unique_id = player:GetUniqueId(), 
        name = player:GetName(),
        network_values = player:GetNetworkValues()
    }
end

-- return the sync data for every player we have stored
function sPlayers:GetAllSyncData()
    local sync_data = {}

    for unique_id, player in pairs(self.players_by_unique_id) do
        sync_data[unique_id] = self:GetPlayerSyncData(player)
    end

    return sync_data
end

-- !! must be __loadFirst compatible. ask Dev_34 if confused
function sPlayers:GetPlayerIdentifiers(source)
    local ids = 
    {
        steam = "",
        license = "",
        live = "",
        discord = "",
        fivem = "",
        ip = ""
    }
    local identifiers, steamIdentifier = GetPlayerIdentifiers(source)
    
    for _, v in pairs(identifiers) do
        if string.find(v, "steam") then
            ids.steam = v:gsub("steam:", "")
        end
        if string.find(v, "license") then
            ids.license = v:gsub("license:", "")
        end
        if string.find(v, "live") then
            ids.live = v:gsub("live:", "")
        end
        if string.find(v, "discord") then
            ids.discord = v:gsub("discord:", "")
        end
        if string.find(v, "fivem") then
            ids.fivem = v:gsub("fivem:", "")
        end
        if string.find(v, "ip") then
            ids.ip = v:gsub("ip:", "")
        end
    end
    
    return ids
end

function sPlayers:GetPlayers()
    return self.players_by_unique_id
end

function sPlayers:GetNumPlayers()
    return count_table(self.players_by_unique_id)
end

-- "source" id: number
function sPlayers:GetById(id)
    id = tonumber(id)
    for player_unique_id, player in pairs(self.players_by_unique_id) do
        if player:GetId() == id then
            return player
        end
    end
end

function sPlayers:GetByUniqueId(unique_id)
    return self.players_by_unique_id[unique_id]
end

function sPlayers:GetBySteamId(steam_id)
    for player_unique_id, player in pairs(self.players_by_unique_id) do
        if player:GetSteamId() == steam_id then
            return player
        end
    end
end


sPlayers = sPlayers()