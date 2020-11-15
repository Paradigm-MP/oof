PlayerManager = class()

function PlayerManager:__init()
    self:SubscribeToEvents()
    self:ListenForNetworkEvents()
end

function PlayerManager:SubscribeToEvents()
    Events:Subscribe("LocalPlayerSpawn", function()
        Network:Send("api/PlayerSpawned")
    end)
end

function PlayerManager:ListenForNetworkEvents()
    Network:Subscribe("PlayerRemoved", self, self.PlayerRemoved)
end

function PlayerManager:PlayerRemoved(args)
    local player = cPlayers:GetByUniqueId(args.player_unique_id)
    assert(cPlayers:GetByUniqueId(args.player_unique_id) ~= nil, "PlayerManager:PlayerRemoved tried to remove player that wasn't being stored")

    if player then
        Events:Fire("PlayerQuit", {player = player})

        player:Disconnected()

        cPlayers:RemovePlayer(args.player_unique_id)

        print("removed Player: ", player)
    end
end

PlayerManager = PlayerManager()