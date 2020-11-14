WeaponTypeEnum = class(Enum)

function WeaponTypeEnum:__init()
    self:EnumInit()


    self.Pistol = 1
    self:SetDescription(self.Pistol, "Pistol")

    self.Repeater = 2
    self:SetDescription(self.Repeater, "Repeater")

    self.Shotgun = 3
    self:SetDescription(self.Shotgun, "Shotgun")

    self.Rifle = 4
    self:SetDescription(self.Rifle, "Rifle")

    self.Sniper = 5
    self:SetDescription(self.Sniper, "Sniper")

    self.Melee = 6
    self:SetDescription(self.Melee, "Melee")
end

WeaponTypeEnum = WeaponTypeEnum()