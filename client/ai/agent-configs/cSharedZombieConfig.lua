SharedZombieConfig = class()

function SharedZombieConfig:Apply(ped_instance)
    local ped = ped_instance:GetPedId()

    -- SetBlockingOfNonTemporaryEvents stops the ped from engaging in combat with players when shot or aimed at
    SetBlockingOfNonTemporaryEvents(ped, true)

    -- SetPedCanRagdoll completely disables ragdolling. it causes odd immediate-drop-to-floor behavior when peds die, but otherwise works as intended. explosions act weirdly
    --SetPedCanRagdoll(ped, false)
    -- SetPedRagdollBlockingFlags stops bullets from making the ped go ragdoll
    SetPedRagdollBlockingFlags(ped, 1)

    -- SetPedCanRagdollFromPlayerImpact stops the player from being able to knock a ped down by sprinting at it
    SetPedCanRagdollFromPlayerImpact(ped, false)
    
    SetEntityMaxHealth(ped, Actor.MAX_HEALTH)
    SetEntityHealth(ped,    Actor.MAX_HEALTH)

    -- remove ped armour completely
    SetPedArmour(ped, 0.0) -- (0.0 -> 100.0)

    -- disables headshot critical damage (which is very important for custom damage to work properly)
    -- does not interfere with detecting headshot damage
    SetPedSuffersCriticalHits(ped, false)

    Chat:Debug("Ran SharedZombieConfig")

    if 1 == 1 then return end
    Citizen.CreateThread(function()
        while true do
            Wait(100)

            --print("setting max health")
            SetEntityMaxHealth(ped, Actor.MAX_HEALTH)
            SetEntityHealth(ped, Actor.MAX_HEALTH)
        end
    end)
end