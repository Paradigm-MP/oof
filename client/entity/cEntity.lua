Entity = class(ValueStorage)

function Entity:__init(ent)
    self:InitializeEntity(ent)
end

function Entity:InitializeEntity(ent)
    self.entity = ent
    self:InitializeValueStorage(self)
end

function Entity:GetEntityId()
    return self.entity
end

function Entity:GetEntity()
    return self.entity
end

function Entity:Exists()
    return DoesEntityExist(self.entity) == 1
end

-- not sure if this works (doesnt seem to work well with timeout on anim)
function Entity:IsPlayingAnimation(anim_dictionary, anim_name)
    return IsEntityPlayingAnim(self.entity, anim_dictionary, anim_name, 3)
end

--[[
    Returns boolean, whether or not this old entity instance can be used again on this frame
]]
function Entity:CanReuse()
    --print("IsAnEntity(self.entity): ", IsAnEntity(self.entity))
    --print("DoesEntityExist(self.entity): ", DoesEntityExist(self.entity))
    return DoesEntityExist(self.entity) and IsAnEntity(self.entity)
end

--[[
    Makes the object kinematic so it is not affected by physics
]]
function Entity:SetKinematic(enabled)
    FreezeEntityPosition(self.entity, enabled)
end

ForceType = {
    MinForce = 0,
    MaxForceRot = 1,
    MinForce2 = 2,
    MaxForceRot2 = 3,
    ForceNoRot = 4,
    ForceRotPlusForce = 5
}

function Entity:ApplyForce(forceType, amount, offset, boneIndex, isDirectionRel, ignoreUpVec, isForceRel)
    ApplyForceToEntity(
        self.entity --[[ Entity ]], 
        forceType --[[ integer ]], 
        amount.x --[[ number ]], 
        amount.y --[[ number ]], 
        amount.z --[[ number ]], 
        offset.x --[[ number ]], 
        offset.y --[[ number ]], 
        offset.z --[[ number ]], 
        boneIndex --[[ integer ]], 
        isDirectionRel --[[ boolean ]], 
        ignoreUpVec --[[ boolean ]], 
        isForceRel --[[ boolean ]], 
        false, 
        true
    )
end

-- other_entity is entity id
-- this boy is a coroutine blocker
function Entity:InterpolateEntityHeadingTowardsEntityBLOCKING(other_entity, duration, callback)
    --Citizen.CreateThread(function()
    local initial_heading = GetEntityHeading(self.entity)
    local interpolated_heading
    local target_heading
    local update_time = 23
    local num_interpolations = math.floor(duration / update_time)
    local max_turn_per_update = 0.1
    local current_heading
    local update_heading_delta
    local abs = math.abs
    local interpolation_factor = .15

    for i = 1, num_interpolations do
        target_heading = self:GetHeadingTowardsEntity(other_entity)
        current_heading = GetEntityHeading(self.entity)
        interpolated_heading = lerp(current_heading, target_heading, interpolation_factor)
        update_heading_delta = abs(interpolated_heading - current_heading)

        local division_factor = 1.5
        while update_heading_delta > 5 do
            interpolated_heading = lerp(current_heading, target_heading, interpolation_factor / division_factor)
            update_heading_delta = abs(interpolated_heading - current_heading)
            division_factor = division_factor + .5
        end
        print("update_heading_delta: ", update_heading_delta)

        SetEntityHeading(self.entity, interpolated_heading)
        Wait(update_time)
    end

    if callback then
        callback()
    end
    --end)
end

-- returns positive number of degrees that the Entity would need to turn in order to be perfectly facing other_entity
function Entity:GetDeltaHeadingTowardsEntity(other_entity)
    return math.abs(self:GetHeadingTowardsEntity(other_entity) - self:GetYaw())
end

function Entity:SetEntityHeadingTowardsEntity(other_entity, ped)
    local entity_type = type(other_entity)

    local heading
    if entity_type == "number" then
        local p1 = GetEntityCoords(self.entity, true)
        local p2 = GetEntityCoords(other_entity, true)

        local dx = p2.x - p1.x
        local dy = p2.y - p1.y

        heading = GetHeadingFromVector_2d(dx, dy)
    elseif is_class_instance(other_entity, Entity) then
        local other_entity_id = other_entity:GetEntityId()
        local p1 = GetEntityCoords(self.entity, true)
        local p2 = GetEntityCoords(other_entity_id, true)

        local dx = p2.x - p1.x
        local dy = p2.y - p1.y

        heading = GetHeadingFromVector_2d(dx, dy)
    end

    SetEntityHeading(self.entity, heading)
end

function Entity:GetHeadingTowardsEntity(other_entity)
    local p1 = GetEntityCoords(self.entity, true)
    local p2 = GetEntityCoords(is_class_instance(other_entity, Entity) and other_entity:GetEntityId() or other_entity, true)

    -- old debug code, remove at some point
    if p1.y - .01 <= 0.0 and p1.y + .01 >= 0 then
        error("p1 is zero")
    end
    if p2.y - .01 <= 0.0 and p2.y + .01 >= 0 then
        error("p2 is zero")
    end
    ---------------------

    local dx = p2.x - p1.x
    local dy = p2.y - p1.y

    return GetHeadingFromVector_2d(dx, dy)
end

function Entity:GetHeightAboveGround()
    return GetEntityHeightAboveGround(self.entity)
end

function Entity:GetPosition()
    return GetEntityCoords(self.entity)
end

function Entity:GetAlpha()
    return GetEntityAlpha(self.entity)
end

function Entity:GetForwardVector()
    return GetEntityForwardVector(self.entity)
end

function Entity:GetHeading()
    return GetEntityPhysicsHeading(self.entity)
end

function Entity:GetYaw()
    return GetEntityHeading(self.entity)
end

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
function Entity:GetHealth()
    return GetEntityHealth(self.entity)
end

function Entity:GetMatrix()
    return GetEntityMatrix(self.entity)
end

--[[
    Return an integer value of entity's maximum health.  
Example:  
- Player = 200 
]]
function Entity:GetMaxHealth()
    return GetEntityMaxHealth(self.entity)
end

--[[
    Returns x,y,z,w
]]
function Entity:GetQuaternion()
    local x, y, z, w = GetEntityQuaternion(self.entity)
    return quat(x,y,z,w)
end

function Entity:GetRotation()
    return GetEntityRotation(self.entity)
    --[[local x, y, z, w = GetEntityQuaternion(self.entity)
    return vector3(x,y,z)]]
end

function Entity:GetModel()
    return GetEntityModel(self.entity)
end

--[[
    Sets the amount of physics damping per axis.

    vertex: (number) ranges from 0-2
    value: (number) amount of daming
]]
function Entity:SetDamping(vertex, value)
    SetDamping(self.entity, vertex, value)
end

--[[
    Gets a position relative to the entity
    Offset values are relative to the entity.  
    x = left/right  
    y = forward/backward  
    z = up/down  
]]
function Entity:GetRelativeOffset(offset)
    return GetOffsetFromEntityInWorldCoords(self.entity, offset.x, offset.y, offset.z)
end

function Entity:GetPitch()
    return GetEntityPitch(self.entity)
end

function Entity:GetRoll()
    return GetEntityRoll(self.entity)
end

function Entity:GetAngularVelocity()
    return GetEntityRotationVelocity(self.entity)
end

--[[
    result is in meters per second  
------------------------------------------------------------  
So would the conversion to mph and km/h, be along the lines of this.  
float speed = GET_ENTITY_SPEED(veh);  
float kmh = (speed * 3.6);  
float mph = (speed * 2.236936);  
]]
function Entity:GetSpeed()
    return GetEntitySpeed(self.entity)
end

function Entity:GetVelocity()
    return GetEntityVelocity(self.entity)
end

function Entity:IsDead()
    return IsEntityDead(self.entity)
end

function Entity:IsVisible()
    return IsEntityVisible(self.entity)
end

function Entity:ResetAlpha()
    ResetEntityAlpha(self.entity)
end

--[[
    Set alpha. skin to true if you don't want skin to be transparent
]]
function Entity:SetAlpha(alpha, skin)
    SetEntityAlpha(self.entity, alpha, skin or false)
end

--[[
    Makes the specified entity (ped, vehicle or object) persistent. 
    Persistent entities will not automatically be removed by the engine.
]]
function Entity:SetAsPersistent()
    SetEntityAsMissionEntity(self.entity, true, true)
end

function Entity:Remove()
    --SetEntityAsNoLongerNeeded(self.entity)
    DeleteEntity(self.entity)
end

-- Returns true if collision enabled, false if collision disabled
function Entity:GetCollision()
    return not GetEntityCollisionDisabled(self.entity)
end

-- Must call this every frame to disable collision
function Entity:ToggleCollision(enabled)
    SetEntityCollision(self.entity, enabled, false)
end

function Entity:SetPosition(pos)
    SetEntityCoords(self.entity, pos.x, pos.y, pos.z, 1, 0, 0, 1)
end

function Entity:SetHeading(heading)
    SetEntityHeading(self.entity, heading)
end

--[[
    health >= 0  
]]
function Entity:SetHealth(health)
    SetEntityHealth(self.entity, health)
end

function Entity:SetInvincible(enabled)
    SetEntityInvincible(self.entity, enabled)
    self.invincible = enabled
end

function Entity:GetInvincible()
    return self.invincible
end

function Entity:SetMaxHealth(health)
    SetEntityMaxHealth(self.entity, health)
end
--[[
    Calling this function disables collision between two entities.
The importance of the order for entity1 and entity2 is unclear.
The third parameter, `thisFrame`, decides whether the collision is 
to be disabled until it is turned back on, or if it's just this frame.
]]
function Entity:SetEntityNoCollisionEntity(entity, thisframe)
    SetEntityNoCollisionEntity(self.entity, entity, thisframe)
end

function Entity:SetQuaternion(q)
    SetEntityQuaternion(self.entity, q.x, q.y, q.z, q.w)
end

function Entity:SetRotation(rot)
    SetEntityRotation(self.entity, rot.x, rot.y, rot.z, 0, true)
end

function Entity:SetVelocity(velo)
    SetEntityVelocity(self.entity, velo.x, velo.y, velo.z)
end

--[[
    Attaches this Entity to another Entity.

    args (in table):
        entity: (Entity) the entity to attach to
        bone_enum: (number, optional) bone enum to attach to
        position: (vector3, optional) position on the entity to attach to
        rotation: (vector3, optional): rotation to attach at
        useSoftPinning (bool, optional): whether to use soft pinning or not
        collision: (bool, optional): if the two objects should collide
        isPed: (bool, optional): if one of the two objects is a Ped
        vertexIndex (number, optional): vertex index
        fixedRot: (bool, optional): whether or not the Entity's rotation stays the same while attached

]]
function Entity:AttachToEntity(args)
    AttachEntityToEntity(
        self.entity --[[ Entity ]], 
        args.entity:GetEntityId() --[[ Entity ]], 
        args.bone_enum and GetEntityBoneIndexByName(args.entity:GetEntityId(), PedBoneEnum:MapToBoneName(args.bone_enum)) or 0 --[[ integer ]], 
        args.position and args.position.x or 0.0 --[[ number ]], 
        args.position and args.position.y or 0.0 --[[ number ]], 
        args.position and args.position.z or 0.0 --[[ number ]], 
        args.rotation and args.rotation.x or 0.0 --[[ number ]], 
        args.rotation and args.rotation.y or 0.0 --[[ number ]], 
        args.rotation and args.rotation.z or 0.0 --[[ number ]], 
        true --[[ boolean ]], 
        args.useSoftPinning or false --[[ boolean ]], 
        args.collision or false --[[ boolean ]], 
        args.isPed or false --[[ boolean ]], 
        args.vertexIndex or 0 --[[ integer ]], 
        args.fixedRot or false --[[ boolean ]], 
        false --[[ boolean ]], 
        false --[[ boolean ]]
    )
end

-- used by cPlayer
function Entity:SetVisible(visible)
    SetEntityVisible(self.entity, visible)
end

-- Bone names here https://github.com/MoosheTV/redm-external/blob/master/External/Bones.cs
function Entity:GetEntityBonePosition(bone_name)
    local bone_index = GetEntityBoneIndexByName(self.entity, bone_name)
    if bone_index == -1 then 
        print("[WARNING] Entity:GetEntityBonePosition bone index was -1")
        return nil
    end
    local bone_position = GetWorldPositionOfEntityBone(self.entity, bone_index)
    return bone_position
end

-- Returns vector3 in degrees of rotation
function Entity:GetBoneRotation(bone_enum)
    return GetWorldRotationOfEntityBone(self.entity, GetEntityBoneIndexByName(self.entity, PedBoneEnum:MapToBoneName(bone_enum)))
end

function Entity:GetPedBonePositionPerformance(bone_enum)
    return GetWorldPositionOfEntityBone(self.entity, GetEntityBoneIndexByName(self.entity, PedBoneEnum:MapToBoneName(bone_enum)))
end

function Entity:IsInWater()
    return IsEntityInWater(self.entity)
end

function Entity:IsInVolume(volume)
    return IsEntityInVolume(self.entity, volume:GetHandle(), true, 1)
end