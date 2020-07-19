SpectateMode = class()

-- TODO: seperate this class into 2 classes: spectate API & behavior to use spectate API

function SpectateMode:__init()
    getter_setter(self, "is_spectating")
    SpectateMode:SetIsSpectating(false)

    self.spectating_player = nil
    self.spectating_player_unique_id = nil

    Events:Subscribe("LocalPlayerDied", function(args) self:LocalPlayerDied(args) end)
    Events:Subscribe("NewRound", function(args) self:NewRound(args) end)
    Events:Subscribe("PlayerQuit", function(args) self:PlayerQuit(args) end)
    Events:Subscribe("PlayerDied", function(args) self:PlayerDied(args) end)
end

function SpectateMode:StartSpectatingPlayer(player)
    Citizen.CreateThread(function()
    
        
    --print("Entity to Spectate :Exists(): ", player:GetEntity():Exists())
    if not player:GetEntity():Exists() then
        Chat:Debug("PLAYER NOT EXIST WHEN TRYING TO SPECTATE TELL DEV NOW")
        return
    end

    LocalPlayer:GetPlayer():Freeze(true)

    local player_position = GetEntityCoords(player:GetPedId())

    if player_position.x < 0.1 and player_position.x > -0.1 and player_position.y < 0.1 and player_position.y > -0.1 and player_position.z < 0.1 then
        Chat:Debug("Failed to spectate - could not get the coords for the player we want to spectate")
        return
    end

    BlackScreen:Show()
    LocalPlayer:Spawn({
        pos = player_position,
        model = "Player_Zero",
        callback = function()
            LocalPlayer:GetPlayer():Freeze(true)
            LocalPlayer:SetInvisible(true)
            Wait(5000)
            LocalPlayer:SetInvisible(true)
            LocalPlayer:GetPlayer():Freeze(true)

            NetworkSetInSpectatorMode(1, player:GetPedId())

            Wait(500)

            BlackScreen:Hide(3000)

            if not NetworkIsPlayerInSpectatorMode(LocalPlayer:GetPlayerId()) then
                Citizen.CreateThread(function()
                    local spectating = NetworkIsPlayerInSpectatorMode(LocalPlayer:GetPlayerId())
                    local player_to_spectate

                    if not spectating then
                        Chat:Debug("Spectating failed initially")
                    end

                    while not spectating do
                        Wait(2000)
                        if GameManager:GetIsGameInProgress() then
                            Chat:Debug("Retrying spectate")
                            NetworkSetInSpectatorMode(1, player:GetPedId())

                            Wait(500)
                            spectating = NetworkIsPlayerInSpectatorMode(LocalPlayer:GetPlayerId())

                            if spectating then
                                self:SpectateActivated(player)
                                break
                            end
                        end
                    end
                end)
            else
                self:SpectateActivated(player)
                Chat:Debug("NetworkIsPlayerInSpectatorMode successfull initially")
            end
            -- TODO: check if the player is valid
            -- entity exists?
            
        end
    })
    
    
    end)
end

-- all the vars to set or other stuff to do when spectate actually starts
function SpectateMode:SpectateActivated(player)
    SpectateMode:SetIsSpectating(true)
    self.spectating_player = player
    self.spectating_player_unique_id = player:GetUniqueId()

    GamePlayUI:StartSpectating({player = self.spectating_player})
end

function SpectateMode:GetRandomPlayerToSpectate()
    for id, player in pairs(cPlayers:GetPlayers()) do
        if player:GetValue("Alive") and not player:GetValue("Down") and not LocalPlayer:IsPlayer(player) then
            return player
        end
    end
end

function SpectateMode:StopSpectating(args)
    --print("a")
    if not SpectateMode:GetIsSpectating() then return end

    --print("b")
    NetworkSetInSpectatorMode(0, self.spectating_player:GetPedId())
    --print("c")
    SpectateMode:SetIsSpectating(false)
    --print("d")

    self.spectating_player = nil
    self.spectating_player_unique_id = nil

    -- TODO: create "StoppedSpectating" event and move this into a subscription to that event
    GamePlayUI:StopSpectating()
    --print("e")

    if args and args.respawn then
        --print("Spectate mode calling GameManager:Respawn()")
        GameManager:Respawn()
    else
        LocalPlayer:SetInvisible(false)
    end
end

function SpectateMode:GetSpectatingPlayer()
    return self.spectating_player
end

function SpectateMode:LocalPlayerDied(args)
    -- Spectate Scenario #1: Enable if LocalPlayer dies
    if GameManager:GetIsGameInProgress() and count_table(GameManager:GetAlivePlayers()) > 0 then
        SpectateMode:Enable(1)
    end
end

function SpectateMode:NewRound(args)
    -- Spectate Scenario #2: Stop spectating when new round starts, if applicable
    if self:GetIsSpectating() then
        -- we dont need to respawn because GameManager:Respawn will LocalPlayer:Spawn for us
        SpectateMode:StopSpectating({respawn = false})
    end
end

function SpectateMode:Enable(a)
    --Chat:Debug("Spectate Random Player " .. tostring(a))
    local found = false

    for id, player in pairs(cPlayers:GetPlayers()) do
        if player:GetValue("Alive") and not player:GetValue("Down") and not LocalPlayer:IsPlayer(player) then
            --Chat:Print("Found player to spectate")
            found = true
            SpectateMode:StartSpectatingPlayer(player)
            break
            return
        end
    end

    if not found then
        Chat:Debug("No player found to spectate")
    end

    -- TODO: remove this, it is test code
    -- spectate actor if no players found
    for id, actor in pairs(ActorManager.actors) do
        if actor:GetReady() and actor:LocalPlayerHasControl() then
            SpectateMode:StartSpectatingPlayer(actor)
            break
            return
        end
    end
end

function SpectateMode:PlayerQuit(args)
    -- Spectate Scenario #2: Spectate someone else if player we are spectating leaves
    -- not sure
    if SpectateMode:GetIsSpectating() then
        local quitting_player_id = args.player:GetUniqueId()
        if quitting_player_id == SpectateMode:GetSpectatingPlayer():GetUniqueId() then
           -- print("Detected Player who is spectating has left")
            --SpectateMode:StopSpectating({respawn = false})
            -- we dont need to stop spectating because the base-game will automatically spectate someone else i think
            -- we override this behavior (which will cause a crash????)
            SpectateMode:StopSpectating({respawn = false})

            Citizen.CreateThread(function(quitting_player_id)
                Wait(1250)

                -- find another player to spectate
                -- TODO: randomize?
                SpectateMode:Enable(35)
            end)
        end
    end
end

-- args.player_unique_id
function SpectateMode:PlayerDied(args)
    if SpectateMode:GetIsSpectating() then
        if args.player_unique_id == SpectateMode:GetSpectatingPlayer():GetUniqueId() then
            SpectateMode:StopSpectating({respawn = false})

            Citizen.CreateThread(function(quitting_player_id)
                Wait(1250)

                -- find another player to spectate
                -- TODO: randomize?
                SpectateMode:Enable(34)
            end)
        end
    end
end

SpectateMode = SpectateMode()