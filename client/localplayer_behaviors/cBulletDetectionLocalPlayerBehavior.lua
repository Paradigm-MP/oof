BulletDetectionLocalPlayerBehavior = class()
BulletDetectionLocalPlayerBehavior.name = "BulletDetectionLocalPlayerBehavior"

--[[
    BulletDetectionLocalPlayerBehavior:
    Detects and tracks bullets fired by the LocalPlayer
]]

function BulletDetectionLocalPlayerBehavior:__init()
    self.active = true
    self.stored_clip_ammo = 0
    
    self:CheckForBulletsFired()
end

function BulletDetectionLocalPlayerBehavior:CheckForBulletsFired()
    Citizen.CreateThread(function()
        local stored_clip_ammo, current_clip_ammo
        local localplayer_has_weapon, localplayer_weapon_enum

        while self.active do
            Wait(1)

            localplayer_has_weapon, localplayer_weapon_enum = LocalPlayer:GetEquippedWeapon()

            if localplayer_has_weapon then
                stored_clip_ammo = self.stored_clip_ammo
                current_clip_ammo = LocalPlayer:GetCurrentClipAmmoForWeapon(localplayer_weapon_enum)

                if stored_clip_ammo ~= current_clip_ammo then
                    print("Detected Clip Ammo Change")
                    if stored_clip_ammo - 1 == current_clip_ammo then
                        print("Detected Bullet Fired")
                    end

                    local aiming_at_entity, entity_id = GetEntityPlayerIsFreeAimingAt(PlayerId())
                    if IsEntityAPed(entity_id) and aiming_at_entity then
                        Chat:Debug("entity: " .. tostring(entity_id))

                        -- verify that localplayer weapon is the last weapon that hit the ped
                        --local weapon_damage_validation_passed = HasPedBeenDamagedByWeapon(entity_id, WeaponEnum:GetWeaponHash(localplayer_weapon_enum), 0)
                        --Chat:Print("HasPedBeenDamagedByWeapon(): " .. tostring(weapon_damage_validation))
                        --if weapon_damage_validation_passed then
                            -- detected damage
                        --end
                    end

                    -- this comes last
                    self.stored_clip_ammo = current_clip_ammo
                end
            end
        end
    end)
end
