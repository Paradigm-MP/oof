RobotBossConfig = class()

function RobotBossConfig:Apply(ped_instance)
    local ped = ped_instance:GetPedId()

    local ped_class = Ped({ped = ped})
    
    -- stops bullets from causing ragdoll
    SetRagdollBlockingFlags(ped, 1)
    SetPedCanRagdoll(ped, false) -- does not stop all ragdolling like id hoped it would

    -- stops the player from being able to knock a ped down by sprinting at it
    SetPedCanRagdollFromPlayerImpact(ped, false)

    -- ped needs to move ped up or otherwise the SetScale will put the ped under the ground
    local current_pos = ped_class:GetPosition()
    ped_class:SetPosition(vector3(current_pos.x, current_pos.y, current_pos.z + 5.0))
    Citizen.CreateThread(function()
        Wait(400)
        ped_class:SetScale(3.2)
    end)

    SetPedCombatAttributes(ped, 0, false) -- stops the ped from using cover
    SetPedCombatAttributes(ped, 1, false) -- stops the ped from using vehicles
    SetPedCombatAttributes(ped, 46, true) -- stops the ped from using vehicles

    SetPedIsDrunk(ped, true) -- not sure if this does anything


    --[[
    SetPedArmour(ped, 100)
	SetPedAccuracy(ped, 25)
	SetPedSeeingRange(ped, 100.0)
	SetPedHearingRange(ped, 80.0)

    SetPedFleeAttributes(ped, 0, 0)
    SetPedCombatAttributes(ped, 16, 1)
    SetPedCombatAttributes(ped, 17, 0)
    SetPedCombatAttributes(ped, 46, 1)
    SetPedCombatAttributes(ped, 1424, 0)
    SetPedCombatAttributes(ped, 5, 1)
    SetPedCombatRange(ped,2)
    SetPedAlertness(ped,3)
    SetAmbientVoiceName(ped, "ALIENS")
    SetPedEnableWeaponBlocking(ped, true)
    SetPedRelationshipGroupHash(ped, GetHashKey("Zombies1"))
    DisablePedPainAudio(ped, true)
    SetPedDiesInWater(ped, false)
    SetPedDiesWhenInjured(ped, false)
    --	PlaceObjectOnGroundProperly(ped)
    SetPedDiesInstantlyInWater(ped, true)
    SetPedIsDrunk(ped, true)
    SetPedConfigFlag(ped,100,1)
    --RequestAnimSet("move_m@drunk@verydrunk") -- non-existent native
    while not HasAnimSetLoaded("move_m@drunk@verydrunk") do
        Wait(1)
    end
    SetPedMovementClipset(ped, "move_m@drunk@verydrunk", 1.0)
    ApplyPedDamagePack(ped,"BigHitByVehicle", 0.0, 9.0)
    ApplyPedDamagePack(ped,"SCR_Dumpster", 0.0, 9.0)
    ApplyPedDamagePack(ped,"SCR_Torture", 0.0, 9.0)
    StopPedSpeaking(ped,true)

    --TaskWanderStandard(ped, 1.0, 10)
    local pspeed = math.random(20,70)
    local pspeed = pspeed/10
    local pspeed = pspeed+0.01
    --SetEntityMaxSpeed(ped, 5.0)

    if not NetworkGetEntityIsNetworked(ped) then
        NetworkRegisterEntityAsNetworked(ped)
    end
    ]]
    
end