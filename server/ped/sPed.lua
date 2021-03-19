Ped = class(Entity)

function Ped:__init(ped_id)
    self.ped_id = ped_id
    self:InitializeEntity(self.ped_id)
end

function Ped:GetPedId()
    return self.ped_id
end

