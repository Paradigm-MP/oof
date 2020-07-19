Weapons = class()

function Weapons:__init()

    self.current_modifier = 1.0
end


function Weapons:SetDamageModifier(modifier)
    self.current_modifier = modifier

    local success, localplayer_weapon_hash = GetCurrentPedWeapon(LocalPlayer:GetPedId())
    if success then
        SetWeaponDamageModifier(localplayer_weapon_hash, tofloat(self.current_modifier))
    end
end

function Weapons:GetAllPossibleBaseDamages(weapon_enum)
    return self.base_damages[weapon_enum]
end


Weapons = Weapons()
