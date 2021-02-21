Object = class(Entity)

Objects = {} -- Global table to keep track of all the objects, indexed by entity id

--[[
    Spawns a new object.

    args (in table)

    model - string of model name
    position - vector3
    rotation (optional) - vector3 of rotation 
    isNetwork (optional) - (bool) whether you want this object to be synced across the network
    quaternion (optional) - quat
    kinematic (optional) - if the object is kinematic or not
    callback (optional) - callback function that is called after the object is spawned
]]
function Object:__init(args)

    assert(type(args.model) == "string" or type(args.model) == "number", 
        "args.model expected to be a string or hash (number)")
    assert(type(args.position) == "vector3", "args.position expected to be a vector3")

    self.hash = type(args.model) == "string" and GetHashKey(args.model) or args.model
    self.model = args.model

    self:InitializeValueStorage(self)

    LoadModel(self.hash, function()
        self.entity = CreateObject(self.hash, args.position.x, args.position.y, args.position.z, args.isNetwork == true, true, true, true, true)
        self:SetQuaternion(type(args.quaternion) == "quat" and args.quaternion or quat(0,0,0,0))
        self:SetKinematic(args.kinematic or false)
        self:SetAsPersistent()
        if args.rotation then self:SetRotation(args.rotation) end

        self:SetPosition(args.position) -- Reset position again because sometimes they move

        Objects[self:GetEntityId()] = self

        if args.callback then
            args.callback(self)
        end
    end)

end

function Object:PlaceOnGroundProperly()
    PlaceObjectOnGroundProperly(self.entity)
end

function Object:GetModel()
    return self.model
end

function Object:GetHash()
    return self.hash
end

function Object:Slide(to_pos, speed, has_collision)
    SlideObject(self:GetEntityId(), to_pos.x, to_pos.y, to_pos.z, speed.x, speed.y, speed.z, has_collision)
end

function Object:Equals(object)
    return object ~= nil and self:GetEntityId() == object:GetEntityId()
end

function Object:Destroy()
    if not self:GetEntityId() then
        print("[WARNING] Tried to destroy object without valid entity id. (did you already remove it?)")
        return
    end
    Objects[self:GetEntityId()] = nil
    self:Remove()
end