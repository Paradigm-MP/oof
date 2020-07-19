PlayerManager = load_first_class()

-- we are using loadFirst here because we want to make sure the playerSpawned subscription doesn't come in too late
-- which could be the result of waiting for a long loadFirst somewhere else
function PlayerManager:__loadFirst()
    Events:Subscribe("LocalPlayerSpawn", function()
        Network:Send("api/PlayerSpawned")
    end)

    self.__loadFirstCompleted = true
end

function PlayerManager:__init()

    self:ListenForNetworkEvents()
end

function PlayerManager:ListenForNetworkEvents()
    Network:Subscribe("PlayerRemoved", function(args) self:PlayerRemoved(args) end)
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