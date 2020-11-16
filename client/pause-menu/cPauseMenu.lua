PauseMenu = class()

function PauseMenu:__init()
    self.enabled_while_dead = false -- If the pause menu can be opened while the player is dead
end

function PauseMenu:SetEnabledWhileDead(enabled)
    self.enabled_while_dead = enabled

    Citizen.CreateThread(function()
        while self.enabled_while_dead do
            --N_0xcc3fdded67bcfc63()
            Wait(0)
        end
    end)
end

function PauseMenu:SetTitle(title)
    Citizen.CreateThread(function()
        AddTextEntry('FE_THDR_GTAO', title)
    end)
end

function PauseMenu:IsActive()
    return IsPauseMenuActive()
end

PauseMenu = PauseMenu()