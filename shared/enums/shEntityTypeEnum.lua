EntityTypeEnum = class(Enum)

function EntityTypeEnum:__init()
    self:EnumInit()

    self.None = 0
    self:SetDescription(self.None, "None")

    self.Ped = 1
    self:SetDescription(self.Ped, "Ped")

    self.Vehicle = 2
    self:SetDescription(self.Vehicle, "Vehicle")

    self.Object = 3
    self:SetDescription(self.Object, "Object")
end

EntityTypeEnum = EntityTypeEnum()