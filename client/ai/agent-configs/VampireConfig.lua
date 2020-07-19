VampireConfig = class()

function VampireConfig:Apply(ped_instance)
    local ped = ped_instance:GetPedId()

    local ped_class = Ped({ped = ped})
    
    -- stops bullets from causing ragdoll
    SetRagdollBlockingFlags(ped, 1)
    SetPedCanRagdoll(ped, false) -- does not stop all ragdolling like id hoped it would

    -- stops the player from being able to knock a ped down by sprinting at it
    SetPedCanRagdollFromPlayerImpact(ped, false)

    SetPedCombatAttributes(ped, 0, false) -- stops the ped from using cover
    SetPedCombatAttributes(ped, 1, false) -- stops the ped from using vehicles
end