ObjectManager = class()

function ObjectManager:__init()
    Events:Subscribe("onResourceStop", self, self.OnResourceStop)
end

function ObjectManager:FindObjectByEntityId(id)
    return Objects[id]
end

-- Clean up all spawned objects on resource stop
function ObjectManager:OnResourceStop(resource_name)
    if GetCurrentResourceName() == resource_name then
        self:RemoveAllObjects()
    end
end

function ObjectManager:RemoveAllObjects()
    for id, object in pairs(Objects) do
        object:Destroy()
    end
    Objects = {}
end

ObjectManager = ObjectManager()

