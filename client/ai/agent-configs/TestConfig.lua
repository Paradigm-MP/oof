TestConfig = class()

function TestConfig:Apply(ped_instance)
    local ped = ped_instance:GetPedId()
    
    -- moved to SharedZombieConfig
    -- SetBlockingOfNonTemporaryEvents stops the ped from engaging in combat with players when shot or aimed at
    --SetBlockingOfNonTemporaryEvents(ped, true)

    -- moved to SharedZombieConfig
    -- SetPedCanRagdoll completely disables ragdolling. it causes odd immediate-drop-to-floor behavior when peds die, but otherwise works as intended. explosions act weirdly
    --SetPedCanRagdoll(ped, false)
    -- SetPedRagdollBlockingFlags stops bullets from making the ped go ragdoll
    --SetPedRagdollBlockingFlags(ped, 1)

    -- moved to SharedZombieConfig
    -- SetPedCanRagdollFromPlayerImpact stops the player from being able to knock a ped down by sprinting at it
    --SetPedCanRagdollFromPlayerImpact(ped, false)

    --SetPedAlternateMovementAnim(
	--ped --[[ Ped ]], 
	--stance --[[ integer ]], 
	--animDictionary --[[ string ]], 
	--animationName --[[ string ]], 
	--p4 --[[ number ]], - 0
	--p5 --[[ boolean ]] - true

    SetPedAlternateMovementAnim(ped, 2, "move_m@drunk@a", "run", 0, true)
    --SetPedAlternateMovementAnim(ped, 2, "move_m@injured", "run", 0, true)

    -- moved to SharedZombieConfig
    -- disables headshot critical damage (which is very important for custom damage to work properly)
    -- does not interfere with detecting headshot damage
    --SetPedSuffersCriticalHits(ped, false)

    -- moved to SharedZombieConfig
    -- remove ped armour completely
    --SetPedArmour(ped, 0.0) -- (0.0 -> 100.0)

    -- moved to SharedZombieConfig
    --SetEntityMaxHealth(ped, Actor.MAX_HEALTH)
    --SetEntityHealth(ped,    Actor.MAX_HEALTH)
end