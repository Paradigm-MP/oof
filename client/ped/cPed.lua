Ped = class(Entity)

Peds = {} -- Table to keep track of all Peds in the world, indexed by net id

--[[
    Creates or keeps track of a ped.

    args (in a table):
    ped - the already created ped that this Ped instance will keep track of

    or 

    pedType - see PedTypes below
    modelName - name of model to load, see https://wiki.rage.mp/index.php?title=Peds
    position - vector3 position of where to spawn the ped
    heading - the heading of the ped (is the Z axis spawn rotation of the ped)
    isNetwork - if the ped is networked
    thisScriptCheck - can be destroyed if it belongs to the calling script.  
    callback (optional) - callback function that is called after the object is spawned

]]
function Ped:__init(args)
    self.ped_id = args.ped
    self:InitializeEntity(self.ped_id)
end

function Ped:UpdatePedId(ped_id)
    self.ped_id = ped_id
    self.entity = self.ped_id
end

function Ped:GetPedId()
    return self.ped_id
end

AnimationFlags =   
{  
    ANIM_FLAG_NORMAL = 0,  
    ANIM_FLAG_REPEAT = 1,  
    ANIM_FLAG_STOP_LAST_FRAME = 2,  
    ANIM_FLAG_UPPERBODY = 16,  -- makes the anim only play on the upper body
    ANIM_FLAG_ENABLE_PLAYER_CONTROL = 32,  
    ANIM_FLAG_CANCELABLE = 120,  -- makes it so you can walk as it plays
}

--[[
    Returns an integer value of entity's current health.  
    Example of range for ped:  
    - Player [0 to 200]  
    - Ped [100 to 200]  
    - Vehicle [0 to 1000]  
    - Object [0 to 1000]  
    Health is actually a float value but this native casts it to int.  
    In order to get the actual value, do:  
    float health = *(float *)(entityAddress + 0x280);  
]]
function Ped:GetHealth()
    return GetEntityHealth(self.ped_id)
end

function Ped:GetMaxHealth()
    return GetPedMaxHealth(self.ped_id)
end

function Ped:SetHealth(health)
    SetEntityHealth(self.ped_id, health)
end

function Ped:GetPosition()
    return GetEntityCoords(self.ped_id)
end

function Ped:SetPosition(pos)
    SetEntityCoords(self.ped_id, pos.x, pos.y, pos.z, 1, 0, 0, 1)
end

--[[
    Makes the ped perform an animation.

    args: (in table)

    animDict - (string) the dictionary containing the animation
    animName - (string) the name of the animation. Full list: www.los-santos-multiplayer.com/dev.airdancer?cxt=anim

    blendInSpeed (optional) - (number, default 8.0f) how fast the animation should blend in
    blendOutSpeed (optional) - (number, default 8.0f) how fast the animation should blend out
    flag (optional) - (AnimationFlags) see above for animation flags and limiting movement
    playbackRate (optional) - (number) how fast it plays, float between 0 and 1
    position (optional) - (vector3) if you want the ped to teleport to a position to perform the anim
    rotation (optional) - (vector3) if you want the ped to rotate a certain way during the anim
    animTime (optional) - (float 0-1) lets you start the animation from a given point
    duration (optional) - (number) how long the animation should last in ms (takes a second or two to take effect)
]]
function Ped:PlayAnim(args)
    local pos_x, pos_y, pos_z = table.unpack(args.position or self:GetPosition())
    local rot_x, rot_y, rot_z = table.unpack(args.rotation or self:GetRotation())

    local heading = GetEntityHeading(self.ped_id)

    Citizen.CreateThread(function()
        LoadAnimDict(args.animDict, function()
            TaskPlayAnimAdvanced(self.ped_id, args.animDict, args.animName, 
                pos_x, pos_y, pos_z, 0, 0, heading, 
                1000.0, args.playbackRate and tofloat(args.playbackRate) or 1.0, args.duration or -1, 
                args.flag or AnimationFlags.ANIM_FLAG_NORMAL, args.animTime or 0.0, 0, 0)
        end)
    end)
end

function Ped:SoftRemove()
    SetEntityAsNoLongerNeeded(self.ped_id)
end

function Ped:Delete()
    --SetEntityAsNoLongerNeeded(self.ped_id)
    DeleteEntity(self.ped_id)
    SetEntityAsNoLongerNeeded(self.ped_id)
end

-- args.other_entity, args.speed
function Ped:PermanentlyFollowEntity(args)
    TaskGoToEntity(self.ped_id, args.other_entity, -1, 0.00001, args.speed, 1073741824.0, 0)
    SetPedKeepTask(self.ped_id, true)
end

function Ped:GetTotalAmmoInWeapon(weaponHash)
    return GetAmmoInPedWeapon(self.ped_id, weaponHash)
end

function Ped:GetAmmoInClipInWeapon(weaponHash)
    local _, ammo = GetAmmoInClip(self.ped_id, weaponHash)
    return ammo
end

function Ped:GetCurrentWeapon()
    -- TODO: test this, not sure if it works (redm has more args)
    local _, weaponHash = GetCurrentPedWeapon(self.ped_id)
    return weaponHash
end

function Ped:IsSliding()
    return Citizen.InvokeNative(0xD6740E14E4CEFC0B, self.ped_id)
end

function Ped:IsArmed()
    return true
    -- TODO: implement
    --return IsPedArmed(self.ped_id, 4)
end

--[[
    Stops a currently playing animation.
    Doesn't work on paused animations (playbackRate = 0)

    args: (in table)
    animDict - (string) the dictionary containing the animation
    animName - (string) the name of the animation. Full list: www.los-santos-multiplayer.com/dev.airdancer?cxt=anim
]]
function Ped:StopAnim(args)
    StopAnimTask(self.ped_id, args.animDict, args.animName, 1.0)
end

--[[
    Makes the ped jump.

    super_jump - (bool) if you want to jump farther
    extra_far - (bool) if you want to jump even farther

    Although if you really want to go far, combine this with SetVelocity
]]
function Ped:Jump(super_jump, extra_far)
    TaskJump(self.ped_id, true, super_jump, extra_far)
end

function Ped:StartScenarioInPlace(scenario_hash, start_delay)
    TaskStartScenarioInPlace(self:GetPedId(), scenario_hash, start_delay or 0, true, false, false, false)
end

function Ped:TurnToFaceCoord(pos, duration)
    TaskTurnPedToFaceCoord(self:GetPedId(), pos.x, pos.y, pos.z, duration)
end

function Ped:SetInfiniteAmmoClip(enabled)
    SetPedInfiniteAmmoClip(self:GetPedId(), enabled)
end

function Ped:SetScale(scale)
    SetPedScale(self:GetPedId(), tofloat(scale))
end

--[[
    Sets the movement clipset (aka how they look when they move) of the Ped.

    clipset - (string) the clipset you want to use. See below for a list.
    time - (number) the time in ms the Ped should blend from its current clipset to this one

    clipsets:
        "ANIM_GROUP_MOVE_BALLISTIC"  
        "ANIM_GROUP_MOVE_LEMAR_ALLEY"  
        "clipset@move@trash_fast_turn"  
        "FEMALE_FAST_RUNNER"  
        "missfbi4prepp1_garbageman"  
        "move_characters@franklin@fire"  
        "move_characters@Jimmy@slow@"  
        "move_characters@michael@fire"  
        "move_f@flee@a"  
        "move_f@scared"  
        "move_f@sexy@a"  
        "move_heist_lester"  
        "move_injured_generic"  
        "move_lester_CaneUp"  
        "move_m@bag"  
        "MOVE_M@BAIL_BOND_NOT_TAZERED"  
        "MOVE_M@BAIL_BOND_TAZERED"  
        "move_m@brave"  
        "move_m@casual@d"  
        "move_m@drunk@moderatedrunk"  
        "MOVE_M@DRUNK@MODERATEDRUNK"  
        "MOVE_M@DRUNK@MODERATEDRUNK_HEAD_UP"  
        "MOVE_M@DRUNK@SLIGHTLYDRUNK"  
        "MOVE_M@DRUNK@VERYDRUNK"  
        "move_m@fire"  
        "move_m@gangster@var_e"  
        "move_m@gangster@var_f"  
        "move_m@gangster@var_i"  
        "move_m@JOG@"  
        "MOVE_M@PRISON_GAURD"  
        "MOVE_P_M_ONE"  
        "MOVE_P_M_ONE_BRIEFCASE"  
        "move_p_m_zero_janitor"  
        "move_p_m_zero_slow"  
        "move_ped_bucket"  
        "move_ped_crouched"  
        "move_ped_mop"  
        "MOVE_M@FEMME@"  
        "MOVE_F@FEMME@"  
        "MOVE_M@GANGSTER@NG"  
        "MOVE_F@GANGSTER@NG"  
        "MOVE_M@POSH@"  
        "MOVE_F@POSH@"  
        "MOVE_M@TOUGH_GUY@"  
        "MOVE_F@TOUGH_GUY@"
]]
function Ped:SetMovementClipset(clipset, time)
    LoadAnimSet(clipset, function()
        SetPedMovementClipset(self.ped_id, clipset, time)
    end)
end

--[[
    Resets any movementclipset set by :SetMovementClipset
]]
function Ped:ResetMovementClipset()
    ResetPedMovementClipset(self.ped_id, 0.0)
end

function Ped:SetWetness(val)
    SetPedWetnessHeight(self.ped_id, val)
end

function Ped:SetMoney(val)
    SetPedMoney(self.ped_id, val)
end

function Ped:IsFatallyInjured()
    return IsPedFatallyInjured(self.ped_id)
end

function Ped:SetDiesInstantlyInWater(enable)
    SetPedDiesInstantlyInWater(self.ped_id, enable)
end

--[[
    Sets the armor of the specified ped.  
    amount: A value between 0 and 100 indicating the value to set the Ped's armor to.  
]]
function Ped:SetArmor(val)
    SetPedArmour(self.ped_id, val)
end

function Ped:IsInParachuteFreeFall()
    return IsPedInParachuteFreeFall(self.ped_id)
end

--[[
    value ranges from 0 to 3.  
]]
function Ped:SetAlertness(val)
    SetPedAlertness(self.ped_id, val)
end

--[[
    ped can not pull out a weapon when true 
]]
function Ped:SetCanTakeOutWeapon(enable)
    SetEnableHandcuffs(self.ped_id, enable)
end

function Ped:IsSwimmingUnderWater()
    return IsPedSwimmingUnderWater(self.ped_id)
end

function Ped:IsSwimming()
    return IsPedSwimming(self.ped_id)
end

function Ped:IsStopped()
    return IsPedStopped(self.ped_id)
end

function Ped:IsShooting()
    return IsPedShooting(self.ped_id)
end

function Ped:IsReloading()
    return IsPedReloading(self.ped_id)
end

function Ped:IsRagdoll()
    return IsPedRagdoll(self.ped_id)
end

function Ped:IsMale()
    return IsPedMale(self.ped_id)
end

function Ped:IsJumping()
    return IsPedJumping(self.ped_id)
end

function Ped:IsInVehicle(vehicle)
    return IsPedInVehicle(self.ped_id, vehicle, false)
end

function Ped:IsInCombatWithPed(target)
    return IsPedInCombat(self.ped_id, target)
end

function Ped:IsHurt()
    return IsPedHurt(self.ped_id)
end

function Ped:IsHumanoid()
    return IsPedHuman(self.ped_id)
end

function Ped:IsFalling()
    return IsPedFalling(self.ped_id)
end

function Ped:IsFacingPed(ped, viewcone)
    return IsPedFacingPed(self.ped_id, ped, viewcone)
end

function Ped:IsDucking()
    return IsPedDucking(self.ped_id)
end

function Ped:IsDead()
    return IsPedDeadOrDying(self.ped_id, 1)
end

function Ped:IsClimbing()
    return IsPedClimbing(self.ped_id)
end

function Ped:IsAPlayer()
    return IsPedAPlayer(self.ped_id)
end

function Ped:GetCarTryingToEnter()
    return GetVehiclePedIsTryingToEnter(self.ped_id)
end

--[[
    Makes ped ragdoll for time in ms
]]
function Ped:SetToRagdoll(time1, time2, mode)
    SetPedToRagdoll(self.ped_id, time1, time2 or 1000, mode or 0, true, true, false)
end

function Ped:IsRagdoll()
    return IsPedRagdoll(self.ped_id)
end

function Ped:ResetRagdollTimer()
    ResetPedRagdollTimer(self.ped_id)
end

function Ped:InVehicle()
    return IsPedInAnyVehicle(self.ped_id, false)
end

function Ped:GetLastVehicle()
    return GetVehiclePedIsIn(self.ped_id, true)
end

function Ped:GetVehicle()
    return GetVehiclePedIsIn(self.ped_id, false)
end

--[[
    Ped Types: (ordered by return priority)  
    Michael = 0  
    Franklin = 1  
    Trevor = 2  
    Army = 29  
    Animal = 28  
    SWAT = 27  
    LSFD = 21  
    Paramedic = 20  
    Cop = 6  
    Male = 4  
    Female = 5   
    Human = 26  
    Note/Exception  
    hc_gunman : 4 // Mix male and female  
    hc_hacker : 4 // Mix male and female  
    mp_f_misty_01 : 4 // Female character  
    s_f_y_ranger_01 : 5 // Ranger  
    s_m_y_ranger_01 : 4 // Ranger  
    s_m_y_uscg_01 : 6 // US Coast Guard  
]]
function Ped:GetType()
    return GetPedType(self.ped_id)
end

if IsRedM then
    function Ped:SetOutfitPreset(outfit)
        SetPedOutfitPreset(self.ped_id, outfit, 0)
    end
end

function Ped:HasWeapon(hash)
    return HasPedGotWeapon(self.ped_id, hash, false)
end

function Ped:SetWeaponAmmo(hash, ammo)
    SetPedAmmo(self.ped_id, hash, ammo)
end

function Ped:GiveWeapon(hash, ammo, equipNow, hand)
    if not self:HasWeapon(hash) then

        if IsFiveM then
            GiveWeaponToPed(
                self.ped_id, 
                hash, 
                ammo, 
                false, 
                equipNow
            )
        else
            GiveWeaponToPed_2(self.ped_id, hash, ammo, equipNow, 1, hand or false, 0.0)
        end
    else
        self:SetWeaponAmmo(hash, self:GetTotalAmmoInWeapon(hash) + ammo)
    end
end

function Ped:GetWeaponMaxAmmo(hash)
    local _, max = GetMaxAmmo(self.ped_id, hash)
    return max == 0 and 9999 or max
end

--[[
    Enables/disables use of the parachute (gives them the parachute to use)
]]
local parachute_hash = GetHashKey("GADGET_PARACHUTE")
function Ped:ToggleParachute(enabled)
    SetPedGadget(self.ped_id, parachute_hash, enabled)
    if enabled then
        self:GiveWeapon(parachute_hash, 1, false, true)
    else
        self:RemoveWeapon(parachute_hash)
    end
end

function Ped:RemoveWeapon(hash)
    RemoveWeaponFromPed(self.ped_id, hash)
end

function Ped:RemoveAllWeapons()
    RemoveAllPedWeapons(self.ped_id, true, true)
end

--[[
    Returns whether the entity is in stealth mode  
]]
function Ped:GetStealhMovement()
    return GetPedStealthMovement(self.ped_id)
end

--[[
    Returns:  
    -1: Normal  
    0: Wearing parachute on back  
    1: Parachute opening  
    2: Parachute open  
    3: Falling to doom (e.g. after exiting parachute)  
    Normal means no parachute? 
]]
function Ped:GetParachuteState()
    return GetPedParachuteState(self.ped_id)
end

function Ped:GetMoney()
    return GetPedMoney(self.ped_id)
end

--[[
    if (GET_PED_CONFIG_FLAG(ped, 78, 1))  
= returns true if ped is aiming/shooting a gun  
]]
function Ped:GetConfigFlag(flag)
    return GetPedConfigFlag(self.ped_id, flag, 1)
end

function Ped:GetCauseOfDeath()
    return GetPedCauseOfDeath(self.ped_id)
end

function Ped:GetArmor()
    return GetPedArmour(self.ped_id)
end

--[[
    Returns the ped's alertness (0-3).  
    Values :   
    0 : Neutral  
    1 : Heard something (gun shot, hit, etc)  
    2 : Knows (the origin of the event)  
    3 : Fully alerted (is facing the event?)  
    If the Ped does not exist, returns -1. 
]]
function Ped:GetAlertness()
    return GetPedAlertness(self.ped_id)
end

function Ped:GetHairColorIndex()
    return GetPedHairColor(self.ped_id)
end

function Ped:ClearTasks()
    ClearPedTasks(self:GetPedId())
end

function Ped:ClearTasksImmediately()
    ClearPedTasksImmediately(self:GetPedId())
end

function Ped:GetHairColor()
    local r, g, b = GetHairRgbColor(self:GetHairColorIndex())
    return Color(r, g, b)
end

function Ped:ClearWetness()
    ClearPedWetness(self.ped_id)
end

function Ped:ApplyDamage(amount, armorFirst)
    ApplyDamageToPed(self.ped_id, amount, armorFirst)
end

function Ped:CanSeePed(ped)
    return CanPedSeePed(self.ped_id, ped.ped)
end

--[[
    Must have a parachute first. Use ToggleParachute to give them one
]]
function Ped:OpenParachute()
    ForcePedToOpenParachute(self.ped_id)
end

function Ped:GetBonePosition(bone)
    return GetWorldPositionOfEntityBone(self.ped_id, bone)
end

function Ped:GetBonePositionWithOffset(bone_enum, offset)
    return GetPedBoneCoords(self.ped_id, GetEntityBoneIndexByName(self.ped_id, PedBoneEnum:MapToBoneName(bone_enum)), offset.x, offset.y, offset.z)
end

-- pastebin.com/D7JMnX1g 
function Ped:GetBoneIndexByName(name)
    return GetEntityBoneIndexByName(self.ped_id, name)
end

-- firing patterns here for now https://github.com/GTA-Network/GTAVTools/blob/master/GTAVHook/GTAV.h
function Ped:ShootAtCoord(pos, duration, firingPattern)
    TaskShootAtCoord(self:GetPedId(), pos.x, pos.y, pos.z, duration, firingPattern)
end

function Ped:ShootAtEntity(target, duration, firingPattern)
    TaskShootAtEntity(self:GetPedId(), target, duration, firingPattern)
end

function Ped:AimAtCoord(pos, duration)
    TaskAimAtCoord(self:GetPedId(), pos.x, pos.y, pos.z, duration, true, true)
end

function Ped:AimGunAtCoord(pos, duration)
    TaskAimGunAtCoord(self:GetPedId(), pos.x, pos.y, pos.z, duration, true, true)
end

function Ped:LookAtCoord(pos, duration)
    TaskLookAtCoord(self:GetPedId(), pos.x, pos.y, pos.z, duration, 0, 2)
end

--[[
    Returns the network id of the ped
]]
function Ped:GetNetId()
    return PedToNet(self.ped_id)
end

--[[
    Returns whether or not this client has control of this ped.
]]
function Ped:NetworkHasControlOfNetworkId()
    return NetworkHasControlOfNetworkId(self:GetNetId())
end

function Ped:DisablePainAudio(disabled)
    DisablePedPainAudio(self:GetPedId(), disabled)
end

function Ped:SetCanRagdoll(can_ragdoll)
    SetPedCanRagdoll(self.ped_id, can_ragdoll)
end

function Ped:IsOnFoot()
    return IsPedOnFoot(self.ped_id)
end

function Ped:IsGettingUp()
    return IsPedGettingUp(self.ped_id)
end

--[[
    OverlayID ranges from 0 to 12, index from 0 to _GET_NUM_OVERLAY_VALUES(overlayID)-1, and opacity from 0.0 to 1.0.   
    overlayID       Part                  Index, to disable  
    0               Blemishes             0 - 23, 255  
    1               Facial Hair           0 - 28, 255  
    2               Eyebrows              0 - 33, 255  
    3               Ageing                0 - 14, 255  
    4               Makeup                0 - 74, 255  
    5               Blush                 0 - 6, 255  
    6               Complexion            0 - 11, 255  
    7               Sun Damage            0 - 10, 255  
    8               Lipstick              0 - 9, 255  
    9               Moles/Freckles        0 - 17, 255  
    10              Chest Hair            0 - 16, 255  
    11              Body Blemishes        0 - 11, 255  
    12              Add Body Blemishes    0 - 1, 255  
]]
function Ped:SetHeadOverlay(overlayID, index, opacity)
    SetPedHeadOverlay(self.ped_id, overlayID, index, tofloat(opacity))
end

-- See https://runtime.fivem.net/doc/natives/?_0x262B14F48D29DE80 for details
function Ped:SetComponentVariation(componentId, drawableId, textureId, paletteId)
    SetPedComponentVariation(self.ped_id, componentId, drawableId, textureId, paletteId)
end

PedTypes =
{  
    PED_TYPE_PLAYER_0, -- michael  
    PED_TYPE_PLAYER_1, -- franklin  
    PED_TYPE_NETWORK_PLAYER,    -- mp character  
    PED_TYPE_PLAYER_2, -- trevor  
    PED_TYPE_CIVMALE,  
    PED_TYPE_CIVFEMALE,  
    PED_TYPE_COP,  
    PED_TYPE_GANG_ALBANIAN,  
    PED_TYPE_GANG_BIKER_1,  
    PED_TYPE_GANG_BIKER_2,  
    PED_TYPE_GANG_ITALIAN,  
    PED_TYPE_GANG_RUSSIAN,  
    PED_TYPE_GANG_RUSSIAN_2,  
    PED_TYPE_GANG_IRISH,  
    PED_TYPE_GANG_JAMAICAN,  
    PED_TYPE_GANG_AFRICAN_AMERICAN,  
    PED_TYPE_GANG_KOREAN,  
    PED_TYPE_GANG_CHINESE_JAPANESE,  
    PED_TYPE_GANG_PUERTO_RICAN,  
    PED_TYPE_DEALER,  
    PED_TYPE_MEDIC,  
    PED_TYPE_FIREMAN,  
    PED_TYPE_CRIMINAL,  
    PED_TYPE_BUM,  
    PED_TYPE_PROSTITUTE,  
    PED_TYPE_SPECIAL,  
    PED_TYPE_MISSION,  
    PED_TYPE_SWAT,  
    PED_TYPE_ANIMAL,  
    PED_TYPE_ARMY  
};

PedRelationshipType = 
{
    Companion = 0,
    Respect = 1,
    Like = 2,
    Neutral = 3,
    Dislike = 4,
    Hate = 5,
    Pedestrians = 255
}