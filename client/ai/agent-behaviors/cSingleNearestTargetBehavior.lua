SingleNearestTargetBehavior = class()
SingleNearestTargetBehavior.name = "SingleNearestTargetBehavior"
--[[
    SingleNearestTargetBehavior: sets the Actor's target to nearest player, if the target isn't set
]]

function SingleNearestTargetBehavior:BehaviorInitialize(actor)
    self.actor = actor
    getter_setter(actor, "target")
    
    self.active = true
    self.target_scan_delay = 1200
    self.chasing = false
    self.chase_reset_timer = Timer()
    self:ScheduleTargetScanning()
end

function SingleNearestTargetBehavior:ScheduleTargetScanning()
    Citizen.CreateThread(function()
        local target
        local target_position
        local actor_position
        local actor_target_distance

        while self.active do
            Wait(self.target_scan_delay)
            self:AcquireNearestTargetIfNotSet()
        end
    end)
end

function SingleNearestTargetBehavior:AcquireNearestTargetIfNotSet()
    if not self.actor:GetTarget() then
        local closest_player, distance = cPlayers:GetNearestPlayer(self.actor:GetPosition())

        if closest_player and distance < 150 then
            self:SetTarget(closest_player, {
                distance = distance
            })
        end
    end
end

function SingleNearestTargetBehavior:SetTarget(player, args)
    self.actor:SetTarget(player)
    self.actor:FireBehaviorEvent("TargetSet", args)
end
