Explosion = class()

--[[
    Creates an explosion

    args (in table):
        owner (ped id, optional): ped id of the owner of this explosion
        position (vector3): position of the explosion
        type (ExplosionTypes): explosion type
        damageScale (number, optional): damage scale of explosion
        isAudible (bool, optional): whether or not this explosion can be heard
        isInvisible (bool, optional): whether or not this explosion can be seen
        cameraShake (number, optional): amount of camera shake this explosion has
        noDamage (bool, optional): if the explosion does damage or not
]]
function Explosion:Create(args)
    if args.owner ~= nil then
        AddOwnedExplosion(
            args.owner, 
            args.position.x, args.position.y, args.position.z,
            args.type,
            args.damageScale == nil and 1.0 or args.damageScale,
            args.isAudible == nil and true or args.isAudible,
            args.isInvisible == nil and false or args.isInvisible,
            args.cameraShake == nil and 1.0 or args.cameraShake,
            args.noDamage == nil and false or args.noDamage)
    else
        AddExplosion(
            args.position.x, args.position.y, args.position.z,
            args.type,
            args.damageScale == nil and 1.0 or args.damageScale,
            args.isAudible == nil and true or args.isAudible,
            args.isInvisible == nil and false or args.isInvisible,
            args.cameraShake == nil and 1.0 or args.cameraShake,
            args.noDamage == nil and false or args.noDamage)
    end
end

Explosion = Explosion()

if IsRedM then
ExplosionTypes = 
{
    EXP_TAG_DONTCARE = -1,
    EXP_TAG_GRENADE = 0,
    EXP_TAG_STICKYBOMB = 1,
    EXP_TAG_MOLOTOV = 2,
    EXP_TAG_MOLOTOV_VOLATILE = 3,
    EXP_TAG_HI_OCTANE = 4,
    EXP_TAG_CAR = 5,
    EXP_TAG_PLANE = 6,
    EXP_TAG_PETROL_PUMP = 7,
    EXP_TAG_DIR_STEAM = 8,
    EXP_TAG_DIR_FLAME = 9,
    EXP_TAG_DIR_WATER_HYDRANT = 10,
    EXP_TAG_BOAT = 11,
    EXP_TAG_BULLET = 12,
    EXP_TAG_SMOKEGRENADE = 13,
    EXP_TAG_BZGAS = 14,
    EXP_TAG_GAS_CANISTER = 15,
    EXP_TAG_EXTINGUISHER = 16,
    EXP_TAG_TRAIN = 17,
    EXP_TAG_DIR_FLAME_EXPLODE = 18,
    EXP_TAG_VEHICLE_BULLET = 19,
    EXP_TAG_BIRD_CRAP = 20,
    EXP_TAG_FIREWORK = 21,
    EXP_TAG_TORPEDO = 22,
    EXP_TAG_TORPEDO_UNDERWATER = 23,
    EXP_TAG_LANTERN = 24,
    EXP_TAG_DYNAMITE = 25,
    EXP_TAG_DYNAMITESTACK = 26,
    EXP_TAG_DYNAMITE_VOLATILE = 27,
    EXP_TAG_RIVER_BLAST = 28,
    EXP_TAG_PLACED_DYNAMITE = 29,
    EXP_TAG_FIRE_ARROW = 30,
    EXP_TAG_DYNAMITE_ARROW = 31,
    EXP_TAG_PHOSPHOROUS_BULLET = 32,
    EXP_TAG_LIGHTNING_STRIKE = 33,
    EXP_TAG_TRACKING_ARROW = 34,
    EXP_TAG_POISON_BOTTLE = 35
}
end