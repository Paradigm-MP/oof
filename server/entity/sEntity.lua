Entity = class(ValueStorage)

function Entity:__init(entity_id)
    self.entity = entity_id
    self:InitializeEntity(self.entity)
end

function Entity:InitializeEntity(ent)
    self.entity = ent
    self:InitializeValueStorage(self)
end

function Entity:GetEntity()
    return self.entity
end

function Entity:GetEntityId()
    return self.entity
end

function Entity:Remove()
    DeleteEntity(self.entity)
end

function Entity:Exists()
    return DoesEntityExist(self.entity)
end

function Entity:GetNetworkId()
    return NetworkGetNetworkIdFromEntity(self.entity)
end

function Entity:GetNetworkOwner()
    return NetworkGetEntityOwner(self.entity)
end

function Entity:NetworkGetFirstEntityOwner()
    -- Get first entity owner - with fallback in case of older server version
    return NetworkGetFirstEntityOwner and NetworkGetFirstEntityOwner(self.entity) or NetworkGetEntityOwner(self.entity)
end

function Entity:GetPosition()
    return GetEntityCoords(self.entity)
end

function Entity:GetHeading()
    return GetEntityHeading(self.entity)
end

function Entity:GetHealth()
    return GetEntityHealth(self.entity)
end

function Entity:GetMaxHealth()
    return GetEntityMaxHealth(self.entity)
end

function Entity:GetModel()
    return GetEntityModel(self.entity)
end

function Entity:GetRotation()
    return GetEntityRotation(self.entity)
end

function Entity:GetRotationVelocity()
    return GetEntityRotationVelocity(self.entity)
end

function Entity:GetRoutingBucket()
    return GetEntityRoutingBucket(self.entity)
end

function Entity:SetRoutingBucket(bucket)
    SetEntityRoutingBucket(self.entity, bucket)
end

function Entity:GetType()
    return GetEntityType(self.entity)
end

function Entity:GetVelocity()
    return GetEntityVelocity(self.entity)
end
