-- Class for storing values on stuff

ValueStorage = class()

function ValueStorage:__init()
    self:InitializeValueStorage()
end

function ValueStorage:InitializeValueStorage(cls)
    self.cls = cls -- What class instance has this valuestorage attached to it
    self.values = {} -- All values

    if IsServer then
        self.network_values = {}
    end

    self.id = nil -- Id of the value storage (only needed for networking)
end

--[[
    Sets the network id of this value storage. Needed if you want to use SetNetworkValue.
    Call SetNetworkId with the net id of the entity in order to get synced calls to SetNetworkValue
]]
function ValueStorage:SetValueStorageNetworkId(id)
    self.id = id

    if IsClient then
        self.sub = Network:Subscribe("ValueStorageSetNetworkValue" .. self.id, function(args) self:SetNetworkValueInternal(args) end)
    end
end

function ValueStorage:SetNetworkValueInternal(args)
    assert(self.id ~= nil, "Cannot ValueStorage:SetNetworkValue because id was not set. Set it using SetNetworkId")

    -- Received from server (on client)
    assert(args.id == self.id, "Cannot ValueStorage:SetNetworkValue because id mismatch")
    if self.__is_player_instance then
        Events:Fire("PlayerNetworkValueChanged", {
            player = self,
            name = args.name,
            old_val = self:GetValue(args.name),
            val = args.val
        })
    end
    Events:Fire("NetworkValueChanged", {cls = self.cls, name = args.name, old_val = self:GetValue(args.name), val = args.val})
    self:SetValue(args.name, args.val)
end

function ValueStorage:SetNetworkValue(name, val)
    if IsServer then
        -- Called from server

        if self.__is_player_instance then
            Events:Fire("PlayerNetworkValueChanged", {
                player = self,
                name = name,
                old_val = self:GetValue(name),
                val = val
            })
        end
        
        self:SetValue(name, val)
        self.network_values[name] = val
        Network:Broadcast("ValueStorageSetNetworkValue" .. self.id, {name = name, val = val, id = self.id})
    end
end

function ValueStorage:GetNetworkValues()
    return self.network_values
end

function ValueStorage:SetValue(name, val)
    self.values[name] = val
end

function ValueStorage:GetValue(name)
    return self.values[name]
end

