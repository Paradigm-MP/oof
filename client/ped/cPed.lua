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

if IsFiveM then
    function Ped:GetBonePositionByName(bone_name)
        local bone_id = PedBoneId[bone_name]
        if not bone_id then
            print("[WARNING] Ped:GetBonePositionByName bone_id was -1")
            return nil
        end
        
        local bone_index = self:GetPedBoneIndexById(bone_id)
        if bone_index == -1 then
            print("[WARNING] Ped:GetBonePositionByName bone_index was -1")
            return nil
        end
        
        return self:GetBonePosition(bone_index)
    end
end

function Ped:GetBonePositionWithOffset(bone_enum, offset)
    return GetPedBoneCoords(self.ped_id, GetEntityBoneIndexByName(self.ped_id, PedBoneEnum:MapToBoneName(bone_enum)), offset.x, offset.y, offset.z)
end

-- RedM: pastebin.com/D7JMnX1g 
function Ped:GetBoneIndexByName(name)
    return GetEntityBoneIndexByName(self.ped_id, name)
end

-- FiveM, use PedBoneId (below)
function Ped:GetPedBoneIndexById(boneId)
    return GetPedBoneIndex(self.ped_id, boneId) 
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

if IsFiveM then
    PedBoneId = 
    {
        SKEL_ROOT = 0x0,
        SKEL_Pelvis = 0x2E28,
        SKEL_L_Thigh = 0xE39F,
        SKEL_L_Calf = 0xF9BB,
        SKEL_L_Foot = 0x3779,
        SKEL_L_Toe0 = 0x83C,
        EO_L_Foot = 0x84C5,
        EO_L_Toe = 0x68BD,
        IK_L_Foot = 0xFEDD,
        PH_L_Foot = 0xE175,
        MH_L_Knee = 0xB3FE,
        SKEL_R_Thigh = 0xCA72,
        SKEL_R_Calf = 0x9000,
        SKEL_R_Foot = 0xCC4D,
        SKEL_R_Toe0 = 0x512D,
        EO_R_Foot = 0x1096,
        EO_R_Toe = 0x7163,
        IK_R_Foot = 0x8AAE,
        PH_R_Foot = 0x60E6,
        MH_R_Knee = 0x3FCF,
        RB_L_ThighRoll = 0x5C57,
        RB_R_ThighRoll = 0x192A,
        SKEL_Spine_Root = 0xE0FD,
        SKEL_Spine0 = 0x5C01,
        SKEL_Spine1 = 0x60F0,
        SKEL_Spine2 = 0x60F1,
        SKEL_Spine3 = 0x60F2,
        SKEL_L_Clavicle = 0xFCD9,
        SKEL_L_UpperArm = 0xB1C5,
        SKEL_L_Forearm = 0xEEEB,
        SKEL_L_Hand = 0x49D9,
        SKEL_L_Finger00 = 0x67F2,
        SKEL_L_Finger01 = 0xFF9,
        SKEL_L_Finger02 = 0xFFA,
        SKEL_L_Finger10 = 0x67F3,
        SKEL_L_Finger11 = 0x1049,
        SKEL_L_Finger12 = 0x104A,
        SKEL_L_Finger20 = 0x67F4,
        SKEL_L_Finger21 = 0x1059,
        SKEL_L_Finger22 = 0x105A,
        SKEL_L_Finger30 = 0x67F5,
        SKEL_L_Finger31 = 0x1029,
        SKEL_L_Finger32 = 0x102A,
        SKEL_L_Finger40 = 0x67F6,
        SKEL_L_Finger41 = 0x1039,
        SKEL_L_Finger42 = 0x103A,
        PH_L_Hand = 0xEB95,
        IK_L_Hand = 0x8CBD,
        RB_L_ForeArmRoll = 0xEE4F,
        RB_L_ArmRoll = 0x1470,
        MH_L_Elbow = 0x58B7,
        SKEL_R_Clavicle = 0x29D2,
        SKEL_R_UpperArm = 0x9D4D,
        SKEL_R_Forearm = 0x6E5C,
        SKEL_R_Hand = 0xDEAD,
        SKEL_R_Finger00 = 0xE5F2,
        SKEL_R_Finger01 = 0xFA10,
        SKEL_R_Finger02 = 0xFA11,
        SKEL_R_Finger10 = 0xE5F3,
        SKEL_R_Finger11 = 0xFA60,
        SKEL_R_Finger12 = 0xFA61,
        SKEL_R_Finger20 = 0xE5F4,
        SKEL_R_Finger21 = 0xFA70,
        SKEL_R_Finger22 = 0xFA71,
        SKEL_R_Finger30 = 0xE5F5,
        SKEL_R_Finger31 = 0xFA40,
        SKEL_R_Finger32 = 0xFA41,
        SKEL_R_Finger40 = 0xE5F6,
        SKEL_R_Finger41 = 0xFA50,
        SKEL_R_Finger42 = 0xFA51,
        PH_R_Hand = 0x6F06,
        IK_R_Hand = 0x188E,
        RB_R_ForeArmRoll = 0xAB22,
        RB_R_ArmRoll = 0x90FF,
        MH_R_Elbow = 0xBB0,
        SKEL_Neck_1 = 0x9995,
        SKEL_Head = 0x796E,
        IK_Head = 0x322C,
        FACIAL_facialRoot = 0xFE2C,
        FB_L_Brow_Out_000 = 0xE3DB,
        FB_L_Lid_Upper_000 = 0xB2B6,
        FB_L_Eye_000 = 0x62AC,
        FB_L_CheekBone_000 = 0x542E,
        FB_L_Lip_Corner_000 = 0x74AC,
        FB_R_Lid_Upper_000 = 0xAA10,
        FB_R_Eye_000 = 0x6B52,
        FB_R_CheekBone_000 = 0x4B88,
        FB_R_Brow_Out_000 = 0x54C,
        FB_R_Lip_Corner_000 = 0x2BA6,
        FB_Brow_Centre_000 = 0x9149,
        FB_UpperLipRoot_000 = 0x4ED2,
        FB_UpperLip_000 = 0xF18F,
        FB_L_Lip_Top_000 = 0x4F37,
        FB_R_Lip_Top_000 = 0x4537,
        FB_Jaw_000 = 0xB4A0,
        FB_LowerLipRoot_000 = 0x4324,
        FB_LowerLip_000 = 0x508F,
        FB_L_Lip_Bot_000 = 0xB93B,
        FB_R_Lip_Bot_000 = 0xC33B,
        FB_Tongue_000 = 0xB987,
        RB_Neck_1 = 0x8B93,
        SPR_L_Breast = 0xFC8E,
        SPR_R_Breast = 0x885F,
        IK_Root = 0xDD1C,
        SKEL_Neck_2 = 0x5FD4,
        SKEL_Pelvis1 = 0xD003,
        SKEL_PelvisRoot = 0x45FC,
        SKEL_SADDLE = 0x9524,
        MH_L_CalfBack = 0x1013,
        MH_L_ThighBack = 0x600D,
        SM_L_Skirt = 0xC419,
        MH_R_CalfBack = 0xB013,
        MH_R_ThighBack = 0x51A3,
        SM_R_Skirt = 0x7712,
        SM_M_BackSkirtRoll = 0xDBB,
        SM_L_BackSkirtRoll = 0x40B2,
        SM_R_BackSkirtRoll = 0xC141,
        SM_M_FrontSkirtRoll = 0xCDBB,
        SM_L_FrontSkirtRoll = 0x9B69,
        SM_R_FrontSkirtRoll = 0x86F1,
        SM_CockNBalls_ROOT = 0xC67D,
        SM_CockNBalls = 0x9D34,
        MH_L_Finger00 = 0x8C63,
        MH_L_FingerBulge00 = 0x5FB8,
        MH_L_Finger10 = 0x8C53,
        MH_L_FingerTop00 = 0xA244,
        MH_L_HandSide = 0xC78A,
        MH_Watch = 0x2738,
        MH_L_Sleeve = 0x933C,
        MH_R_Finger00 = 0x2C63,
        MH_R_FingerBulge00 = 0x69B8,
        MH_R_Finger10 = 0x2C53,
        MH_R_FingerTop00 = 0xEF4B,
        MH_R_HandSide = 0x68FB,
        MH_R_Sleeve = 0x92DC,
        FACIAL_jaw = 0xB21,
        FACIAL_underChin = 0x8A95,
        FACIAL_L_underChin = 0x234E,
        FACIAL_chin = 0xB578,
        FACIAL_chinSkinBottom = 0x98BC,
        FACIAL_L_chinSkinBottom = 0x3E8F,
        FACIAL_R_chinSkinBottom = 0x9E8F,
        FACIAL_tongueA = 0x4A7C,
        FACIAL_tongueB = 0x4A7D,
        FACIAL_tongueC = 0x4A7E,
        FACIAL_tongueD = 0x4A7F,
        FACIAL_tongueE = 0x4A80,
        FACIAL_L_tongueE = 0x35F2,
        FACIAL_R_tongueE = 0x2FF2,
        FACIAL_L_tongueD = 0x35F1,
        FACIAL_R_tongueD = 0x2FF1,
        FACIAL_L_tongueC = 0x35F0,
        FACIAL_R_tongueC = 0x2FF0,
        FACIAL_L_tongueB = 0x35EF,
        FACIAL_R_tongueB = 0x2FEF,
        FACIAL_L_tongueA = 0x35EE,
        FACIAL_R_tongueA = 0x2FEE,
        FACIAL_chinSkinTop = 0x7226,
        FACIAL_L_chinSkinTop = 0x3EB3,
        FACIAL_chinSkinMid = 0x899A,
        FACIAL_L_chinSkinMid = 0x4427,
        FACIAL_L_chinSide = 0x4A5E,
        FACIAL_R_chinSkinMid = 0xF5AF,
        FACIAL_R_chinSkinTop = 0xF03B,
        FACIAL_R_chinSide = 0xAA5E,
        FACIAL_R_underChin = 0x2BF4,
        FACIAL_L_lipLowerSDK = 0xB9E1,
        FACIAL_L_lipLowerAnalog = 0x244A,
        FACIAL_L_lipLowerThicknessV = 0xC749,
        FACIAL_L_lipLowerThicknessH = 0xC67B,
        FACIAL_lipLowerSDK = 0x7285,
        FACIAL_lipLowerAnalog = 0xD97B,
        FACIAL_lipLowerThicknessV = 0xC5BB,
        FACIAL_lipLowerThicknessH = 0xC5ED,
        FACIAL_R_lipLowerSDK = 0xA034,
        FACIAL_R_lipLowerAnalog = 0xC2D9,
        FACIAL_R_lipLowerThicknessV = 0xC6E9,
        FACIAL_R_lipLowerThicknessH = 0xC6DB,
        FACIAL_nose = 0x20F1,
        FACIAL_L_nostril = 0x7322,
        FACIAL_L_nostrilThickness = 0xC15F,
        FACIAL_noseLower = 0xE05A,
        FACIAL_L_noseLowerThickness = 0x79D5,
        FACIAL_R_noseLowerThickness = 0x7975,
        FACIAL_noseTip = 0x6A60,
        FACIAL_R_nostril = 0x7922,
        FACIAL_R_nostrilThickness = 0x36FF,
        FACIAL_noseUpper = 0xA04F,
        FACIAL_L_noseUpper = 0x1FB8,
        FACIAL_noseBridge = 0x9BA3,
        FACIAL_L_nasolabialFurrow = 0x5ACA,
        FACIAL_L_nasolabialBulge = 0xCD78,
        FACIAL_L_cheekLower = 0x6907,
        FACIAL_L_cheekLowerBulge1 = 0xE3FB,
        FACIAL_L_cheekLowerBulge2 = 0xE3FC,
        FACIAL_L_cheekInner = 0xE7AB,
        FACIAL_L_cheekOuter = 0x8161,
        FACIAL_L_eyesackLower = 0x771B,
        FACIAL_L_eyeball = 0x1744,
        FACIAL_L_eyelidLower = 0x998C,
        FACIAL_L_eyelidLowerOuterSDK = 0xFE4C,
        FACIAL_L_eyelidLowerOuterAnalog = 0xB9AA,
        FACIAL_L_eyelashLowerOuter = 0xD7F6,
        FACIAL_L_eyelidLowerInnerSDK = 0xF151,
        FACIAL_L_eyelidLowerInnerAnalog = 0x8242,
        FACIAL_L_eyelashLowerInner = 0x4CCF,
        FACIAL_L_eyelidUpper = 0x97C1,
        FACIAL_L_eyelidUpperOuterSDK = 0xAF15,
        FACIAL_L_eyelidUpperOuterAnalog = 0x67FA,
        FACIAL_L_eyelashUpperOuter = 0x27B7,
        FACIAL_L_eyelidUpperInnerSDK = 0xD341,
        FACIAL_L_eyelidUpperInnerAnalog = 0xF092,
        FACIAL_L_eyelashUpperInner = 0x9B1F,
        FACIAL_L_eyesackUpperOuterBulge = 0xA559,
        FACIAL_L_eyesackUpperInnerBulge = 0x2F2A,
        FACIAL_L_eyesackUpperOuterFurrow = 0xC597,
        FACIAL_L_eyesackUpperInnerFurrow = 0x52A7,
        FACIAL_forehead = 0x9218,
        FACIAL_L_foreheadInner = 0x843,
        FACIAL_L_foreheadInnerBulge = 0x767C,
        FACIAL_L_foreheadOuter = 0x8DCB,
        FACIAL_skull = 0x4221,
        FACIAL_foreheadUpper = 0xF7D6,
        FACIAL_L_foreheadUpperInner = 0xCF13,
        FACIAL_L_foreheadUpperOuter = 0x509B,
        FACIAL_R_foreheadUpperInner = 0xCEF3,
        FACIAL_R_foreheadUpperOuter = 0x507B,
        FACIAL_L_temple = 0xAF79,
        FACIAL_L_ear = 0x19DD,
        FACIAL_L_earLower = 0x6031,
        FACIAL_L_masseter = 0x2810,
        FACIAL_L_jawRecess = 0x9C7A,
        FACIAL_L_cheekOuterSkin = 0x14A5,
        FACIAL_R_cheekLower = 0xF367,
        FACIAL_R_cheekLowerBulge1 = 0x599B,
        FACIAL_R_cheekLowerBulge2 = 0x599C,
        FACIAL_R_masseter = 0x810,
        FACIAL_R_jawRecess = 0x93D4,
        FACIAL_R_ear = 0x1137,
        FACIAL_R_earLower = 0x8031,
        FACIAL_R_eyesackLower = 0x777B,
        FACIAL_R_nasolabialBulge = 0xD61E,
        FACIAL_R_cheekOuter = 0xD32,
        FACIAL_R_cheekInner = 0x737C,
        FACIAL_R_noseUpper = 0x1CD6,
        FACIAL_R_foreheadInner = 0xE43,
        FACIAL_R_foreheadInnerBulge = 0x769C,
        FACIAL_R_foreheadOuter = 0x8FCB,
        FACIAL_R_cheekOuterSkin = 0xB334,
        FACIAL_R_eyesackUpperInnerFurrow = 0x9FAE,
        FACIAL_R_eyesackUpperOuterFurrow = 0x140F,
        FACIAL_R_eyesackUpperInnerBulge = 0xA359,
        FACIAL_R_eyesackUpperOuterBulge = 0x1AF9,
        FACIAL_R_nasolabialFurrow = 0x2CAA,
        FACIAL_R_temple = 0xAF19,
        FACIAL_R_eyeball = 0x1944,
        FACIAL_R_eyelidUpper = 0x7E14,
        FACIAL_R_eyelidUpperOuterSDK = 0xB115,
        FACIAL_R_eyelidUpperOuterAnalog = 0xF25A,
        FACIAL_R_eyelashUpperOuter = 0xE0A,
        FACIAL_R_eyelidUpperInnerSDK = 0xD541,
        FACIAL_R_eyelidUpperInnerAnalog = 0x7C63,
        FACIAL_R_eyelashUpperInner = 0x8172,
        FACIAL_R_eyelidLower = 0x7FDF,
        FACIAL_R_eyelidLowerOuterSDK = 0x1BD,
        FACIAL_R_eyelidLowerOuterAnalog = 0x457B,
        FACIAL_R_eyelashLowerOuter = 0xBE49,
        FACIAL_R_eyelidLowerInnerSDK = 0xF351,
        FACIAL_R_eyelidLowerInnerAnalog = 0xE13,
        FACIAL_R_eyelashLowerInner = 0x3322,
        FACIAL_L_lipUpperSDK = 0x8F30,
        FACIAL_L_lipUpperAnalog = 0xB1CF,
        FACIAL_L_lipUpperThicknessH = 0x37CE,
        FACIAL_L_lipUpperThicknessV = 0x38BC,
        FACIAL_lipUpperSDK = 0x1774,
        FACIAL_lipUpperAnalog = 0xE064,
        FACIAL_lipUpperThicknessH = 0x7993,
        FACIAL_lipUpperThicknessV = 0x7981,
        FACIAL_L_lipCornerSDK = 0xB1C,
        FACIAL_L_lipCornerAnalog = 0xE568,
        FACIAL_L_lipCornerThicknessUpper = 0x7BC,
        FACIAL_L_lipCornerThicknessLower = 0xDD42,
        FACIAL_R_lipUpperSDK = 0x7583,
        FACIAL_R_lipUpperAnalog = 0x51CF,
        FACIAL_R_lipUpperThicknessH = 0x382E,
        FACIAL_R_lipUpperThicknessV = 0x385C,
        FACIAL_R_lipCornerSDK = 0xB3C,
        FACIAL_R_lipCornerAnalog = 0xEE0E,
        FACIAL_R_lipCornerThicknessUpper = 0x54C3,
        FACIAL_R_lipCornerThicknessLower = 0x2BBA,
        MH_MulletRoot = 0x3E73,
        MH_MulletScaler = 0xA1C2,
        MH_Hair_Scale = 0xC664,
        MH_Hair_Crown = 0x1675,
        SM_Torch = 0x8D6,
        FX_Light = 0x8959,
        FX_Light_Scale = 0x5038,
        FX_Light_Switch = 0xE18E,
        BagRoot = 0xAD09,
        BagPivotROOT = 0xB836,
        BagPivot = 0x4D11,
        BagBody = 0xAB6D,
        BagBone_R = 0x937,
        BagBone_L = 0x991,
        SM_LifeSaver_Front = 0x9420,
        SM_R_Pouches_ROOT = 0x2962,
        SM_R_Pouches = 0x4141,
        SM_L_Pouches_ROOT = 0x2A02,
        SM_L_Pouches = 0x4B41,
        SM_Suit_Back_Flapper = 0xDA2D,
        SPR_CopRadio = 0x8245,
        SM_LifeSaver_Back = 0x2127,
        MH_BlushSlider = 0xA0CE,
        SKEL_Tail_01 = 0x347,
        SKEL_Tail_02 = 0x348,
        MH_L_Concertina_B = 0xC988,
        MH_L_Concertina_A = 0xC987,
        MH_R_Concertina_B = 0xC8E8,
        MH_R_Concertina_A = 0xC8E7,
        MH_L_ShoulderBladeRoot = 0x8711,
        MH_L_ShoulderBlade = 0x4EAF,
        MH_R_ShoulderBladeRoot = 0x3A0A,
        MH_R_ShoulderBlade = 0x54AF,
        FB_R_Ear_000 = 0x6CDF,
        SPR_R_Ear = 0x63B6,
        FB_L_Ear_000 = 0x6439,
        SPR_L_Ear = 0x5B10,
        FB_TongueA_000 = 0x4206,
        FB_TongueB_000 = 0x4207,
        FB_TongueC_000 = 0x4208,
        SKEL_L_Toe1 = 0x1D6B,
        SKEL_R_Toe1 = 0xB23F,
        SKEL_Tail_03 = 0x349,
        SKEL_Tail_04 = 0x34A,
        SKEL_Tail_05 = 0x34B,
        SPR_Gonads_ROOT = 0xBFDE,
        SPR_Gonads = 0x1C00,
        FB_L_Brow_Out_001 = 0xE3DB,
        FB_L_Lid_Upper_001 = 0xB2B6,
        FB_L_Eye_001 = 0x62AC,
        FB_L_CheekBone_001 = 0x542E,
        FB_L_Lip_Corner_001 = 0x74AC,
        FB_R_Lid_Upper_001 = 0xAA10,
        FB_R_Eye_001 = 0x6B52,
        FB_R_CheekBone_001 = 0x4B88,
        FB_R_Brow_Out_001 = 0x54C,
        FB_R_Lip_Corner_001 = 0x2BA6,
        FB_Brow_Centre_001 = 0x9149,
        FB_UpperLipRoot_001 = 0x4ED2,
        FB_UpperLip_001 = 0xF18F,
        FB_L_Lip_Top_001 = 0x4F37,
        FB_R_Lip_Top_001 = 0x4537,
        FB_Jaw_001 = 0xB4A0,
        FB_LowerLipRoot_001 = 0x4324,
        FB_LowerLip_001 = 0x508F,
        FB_L_Lip_Bot_001 = 0xB93B,
        FB_R_Lip_Bot_001 = 0xC33B,
        FB_Tongue_001 = 0xB987
    }
end