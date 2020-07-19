PlayerManager = class()

function PlayerManager:__init()
    -- If whitelist is enabled or not
    self.whitelist_enabled = GetConvarInt("whitelist_enabled", 0) == 1
    self.original_server_name = GetConvar("sv_hostname", "")
    print("Whitelist enabled: " .. tostring(self.whitelist_enabled))

    --[[if self.whitelist_enabled  then
        SetConvar("sv_hostname", 
            self.original_server_name .. string.format(" [%sWHITELIST%s]", 
            Colors.Console.Yellow, Colors.Console.Default))
    end]]

    self.max_players = GetConvarInt('sv_maxclients', 32)
    self.queue = {} -- Queue of players who are waiting to get into the server
    self.num_players_connected = #GetPlayers()

    self:ListenForLocalEvents()
    self:ListenForNetworkEvents()
end

function PlayerManager:ListenForLocalEvents()
    -- when a player disconnects
    AddEventHandler("playerDropped", function(reason)
        self:PlayerDisconnect(source, reason)
    end)

    -- handle their connection request
    AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
        self:PlayerConnect(source, name, setKickReason, deferrals)
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        self:OnResourceStop(resourceName)
    end)
end

function PlayerManager:ListenForNetworkEvents()
    Network:Subscribe("api/RequestApiPlayerData", function(args) self:PlayerInitialDataRequest(args) end)
    Network:Subscribe("api/ClientReady", function(args) self:ClientReady(args) end)
end

-- this comes from cPlayers:__loadFirst()
function PlayerManager:PlayerInitialDataRequest(data)
    sPlayers:AddPlayer(data.source)
    self:SyncConnectedPlayers() -- send the updated players list to every client
end

function PlayerManager:ClientReady(args)
    -- fired after a client has executed all the firstLoads, inits, and postloads of all their classes
    Events:Fire("ClientReady", {player = args.player})
end

-- Reset name to default if the api is stopped
function PlayerManager:OnResourceStop(resourceName)
    if resourceName == GetCurrentResourceName() then
        SetConvar("sv_hostname", self.original_server_name)
    end
end

function PlayerManager:PlayerDisconnect(source, reason)
    self.num_players_connected = self.num_players_connected - 1
    local player = sPlayers:GetById(source)
    if not player then -- can be caused by connect (not fully), and then disconnect
        print("player not found on PlayerDisconnect")
        return
    end
    local player_unique_id = player:GetUniqueId()

    print(string.format("%s%s (%i | %s | %s) left the server.%s", 
        Colors.Console.Yellow, player:GetName(), player:GetId(), player:GetUniqueId(), tostring(player:GetIP()), Colors.Console.Default))

    player:Disconnected()

    sPlayers:RemovePlayer(player_unique_id)

    Events:Fire("PlayerQuit", {player = player, reason = reason})
    Network:Send("PlayerRemoved", -1, {player_unique_id = player_unique_id})
end

--[[
    Returns the number of players who are either fully connected to the server or 
    are connecting past the queue.
]]
function PlayerManager:GetNumPlayersConnected()
    return self.num_players_connected
end

function PlayerManager:PlayerConnect(source, name, setKickReason, deferrals)

    -- First, check steam id
    local identifiers, steamIdentifier = GetPlayerIdentifiers(source)
    deferrals.defer()

    deferrals.update(NAPI_Config.Deferrals.CheckingSteamId)

    --[[for _, v in pairs(identifiers) do
        if string.find(v, "steam") then
            steamIdentifier = v
            break
        end
    end]]

    --[[if not steamIdentifier then
        deferrals.done(NAPI_Config.Deferrals.NotConnectedToSteam)
        CancelEvent()
        return
    else]]
    --if not self.whitelist_enabled or IsPlayerAceAllowed(source, "whitelist") then
        deferrals.update(NAPI_Config.Deferrals.Connecting)
    --[[else
        deferrals.done(NAPI_Config.Deferrals.NotWhitelisted)
        CancelEvent()
        return
    end]]
    --end

    local name = GetPlayerName(source)

    if not name then
        deferrals.done()
        CancelEvent()
        return
    end

    -- Check if someone with the same name is already on the server
    local name_lower = string.lower(name)
    for id, player in pairs(sPlayers:GetPlayers()) do
        if string.lower(player:GetName()) == name_lower then
            deferrals.done(string.format(NAPI_Config.Deferrals.DuplicateName, name))
            CancelEvent()
            return
        end
    end

    Citizen.CreateThread(function()
    -- Check if the server is full or if there's a queue
        if self:GetNumPlayersConnected() >= self.max_players or #self.queue > 0 then
            table.insert(self.queue, source)
            local time_elapsed = 0

            -- While the server is full or they aren't front of the queue, keep them in the queue
            while self:GetNumPlayersConnected() >= self.max_players or self:GetPositionInQueue(source) > 1 do

                -- Stopped connecting to the queue
                if not GetPlayerEndpoint(source) then
                    table.remove(self.queue, self:GetPositionInQueue(source))
                    deferrals.done(NAPI_Config.Deferrals.ConnectionCancelled)
                    CancelEvent()
                    return
                end

                deferrals.update(string.format(NAPI_Config.Deferrals.WaitingInQueue, 
                    name, self:GetLoadingIcons(time_elapsed), tostring(self:GetPositionInQueue(source))))
                
                time_elapsed = time_elapsed + 1
                Wait(250)
            end

            table.remove(self.queue, 1)
        end


        deferrals.update(NAPI_Config.Deferrals.Connected)
        deferrals.done()
        self.num_players_connected = self.num_players_connected + 1
    end)

end

-- Makes a fun little loading animation for those in the queue
function PlayerManager:GetLoadingIcons(time)
    local str = ""
    for i = 1, time % 6 do
        str = str .. NAPI_Config.Deferrals.LoadingIcon
    end
    return str
end

function PlayerManager:GetPositionInQueue(source)
    for pos, src in ipairs(self.queue) do
        if src == source then return pos end
    end
    return '???'
end

function PlayerManager:SyncConnectedPlayers()
    local sync_data = sPlayers:GetAllSyncData()

    Network:Broadcast("api/SyncConnectedPlayers", sync_data)
end

PlayerManager = PlayerManager()