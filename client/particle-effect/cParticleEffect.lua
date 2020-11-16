ParticleEffect = class()

--[[
    Creates a particle.

    args (in table):

    There are 3 ways you can create a particle:
        at a position (ParticleEffectTypes.Position)
        attached to an entity (with an offset) (ParticleEffectTypes.Entity)
        attached to an entity bone (with an offset) (ParticleEffectTypes.Bone)

    bank - (string) effect bank of the effect you want to play. List below
    effect - (string) name of the effect you want to play. List here: https://pastebin.com/N9unUFWY
    type - (ParticleEffectTypes)
        if ParticleEffectTypes.Position, requires these args:
            position - (vector3) the position to create the particle at
        if ParticleEffectTypes.Entity, requires these args:
            entity - (entity) the entity to attach the effect to
            offset - (vector3) the offset from the entity to play the effect
        if ParticleEffectTypes.Entity, requires these args:
            entity - (entity) the entity to attach the effect to
            offset - (vector3) the offset from the entity to play the effect
            bone - (number) the index of the bone to play the effect on

    scale - (number) how big the particle is
    rotation - (vector3) the rotation of the particle
    loop (optional) - (bool) if you want the effect to loop, default false
    axis (optional) - (vector3) if you want to flip axes and get wild (Invert Axis Flags)
    callback (optional) - (func) if you want to do something after the effect is spawned
    
]]
function ParticleEffect:__init(args)
    assert(args.effect ~= nil, "cannot create ParticleEffect without effect")
    assert(args.bank ~= nil, "cannot create ParticleEffect without bank")
    assert(args.type ~= nil, "cannot create ParticleEffect without type")
    assert(args.scale ~= nil, "cannot create ParticleEffect without scale")
    assert(args.rotation ~= nil, "cannot create ParticleEffect without rotation")

    self.effect = args.effect
    self.bank = args.bank
    self.type = args.type
    self.scale = tofloat(args.scale)
    self.rotation = args.rotation
    self.loop = args.loop
    self.axis = axis or vector3(0, 0, 0)
    self.callback = args.callback

    if self.type == ParticleEffectTypes.Position then
        assert(args.position ~= nil, "ParticleEffectTypes.Position specified, but no position given")
        self.position = args.position
    else
        assert(args.entity ~= nil, "ParticleEffectTypes.Entity or Bone specified, but no entity given")
        assert(args.offset ~= nil, "ParticleEffectTypes.Entity or Bone specified, but no offset given")
        self.offset = args.offset
        self.entity = args.entity
        if self.type == ParticleEffectTypes.Bone then
            assert(args.bone ~= nil, "ParticleEffectTypes.Bone specified, but no bone given")
            self.bone = args.bone
        end
    end

    LoadEffectBank(self.bank, function() self:CreateEffect() end)

end

function ParticleEffect:GetEffect()
    return self.effect
end

function ParticleEffect:GetType()
    return self.type
end

function ParticleEffect:GetScale()
    return self.scale
end

function ParticleEffect:GetRotation()
    return self.rotation
end

function ParticleEffect:GetIsLooped()
    return self.loop
end

function ParticleEffect:GetAxis()
    return self.axis
end

function ParticleEffect:GetPosition()
    return self.position
end

function ParticleEffect:GetOffset()
    return self.offset
end

function ParticleEffect:GetEntity()
    return self.entity
end

function ParticleEffect:GetBone()
    return self.bone
end

function ParticleEffect:GetColor()
    return self.color
end

function ParticleEffect:GetHandle()
    return self.handle
end

function ParticleEffect:Exists()
    return DoesParticleFxLoopedExist(self.handle)
end

--[[
    Only works for looped effects
]]
function ParticleEffect:SetScale(scale)
    if self.loop then
        self.scale = scale
        SetParticleFxLoopedScale(self.handle, scale)
    end
end

--[[
    Only works for looped effects
]]
function ParticleEffect:SetProperty(propertyName, amount)
    if self.loop then
        SetParticleFxLoopedEvolution(self.handle, propertyName, amount, 0)
    end
end

--[[
    Only works on some particle effects, and only works on looped effects
]]
function ParticleEffect:SetColor(color)
    if self.loop then
        self.color = color
        SetParticleFxLoopedColour(self.handle, color.r, color.g, color.b, 0)
    end
end

function ParticleEffect:Remove()
    RemoveParticleFx(self.handle, true)
end

function ParticleEffect:CreateEffect()

    UseParticleFxAssetNextCall(self.bank)
    if self.type == ParticleEffectTypes.Position then
        if self.loop then
            self.handle = StartParticleFxLoopedAtCoord(
                self.effect,
                self.position.x, self.position.y, self.position.z,
                self.rotation.x, self.rotation.y, self.rotation.z,
                self.scale, self.axis.x, self.axis.y, self.axis.z, 0
            )
        else
            self.handle = StartParticleFxNonLoopedAtCoord(
                self.effect,
                self.position.x, self.position.y, self.position.z,
                self.rotation.x, self.rotation.y, self.rotation.z,
                self.scale, self.axis.x, self.axis.y, self.axis.z, 0
            )
        end
    elseif self.type == ParticleEffectTypes.Entity then
        if self.loop then
            self.handle = StartParticleFxLoopedOnEntity(
                self.effect, self.entity,
                self.offset.x, self.offset.y, self.offset.z,
                self.rotation.x, self.rotation.y, self.rotation.z,
                self.scale, self.axis.x, self.axis.y, self.axis.z
            )
        else
            self.handle = StartParticleFxNonLoopedOnEntity(
                self.effect, self.entity,
                self.offset.x, self.offset.y, self.offset.z,
                self.rotation.x, self.rotation.y, self.rotation.z,
                self.scale, self.axis.x, self.axis.y, self.axis.z
            )
        end
    elseif self.type == ParticleEffectTypes.Bone then 
        if self.loop then
            self.handle = StartParticleFxLoopedOnEntityBone(
                self.effect, self.entity,
                self.offset.x, self.offset.y, self.offset.z,
                self.rotation.x, self.rotation.y, self.rotation.z, self.bone,
                self.scale, self.axis.x, self.axis.y, self.axis.z
            )
        else
            -- IF something breaks, you used loop = false with type = bone on a non ped bone
            self.handle = StartParticleFxNonLoopedOnPedBone(
                self.effect, self.entity,
                self.offset.x, self.offset.y, self.offset.z,
                self.rotation.x, self.rotation.y, self.rotation.z, self.bone,
                self.scale, self.axis.x, self.axis.y, self.axis.z
            )
        end
    end
    
    if self.callback then
        self.callback(self)
    end
end

ParticleEffectTypes = {Position = 1, Entity = 2, Bone = 3}