RandomOffsetSimpleChaseBehavior = class()
RandomOffsetSimpleChaseBehavior.name = "RandomOffsetSimpleChaseBehavior"
--[[
    RandomOffsetSimpleChaseBehavior:
    Sets the task for the Ped to follow some entity using self.target.
    Picks a random, small offset from the target position for the Ped to.
    Configurable threshold for the Ped to remove offset and head directly towards the target position.

    Compatibility:
        * compatible with single target behaviors
]]

function RandomOffsetSimpleChaseBehavior:BehaviorInitialize(actor)
    self.actor = actor
    self.offset_chasing = true -- if false, then we are direct chasing
    self.active = true
    self.monitoring = false
    
    -- configurables:
    self.distance_check_cooldown = 500
    self.inactive_wait_time = self.distance_check_cooldown * 2
    self.direct_chase_distance = 5 -- if Actor is closer than this distance, do direct chase, otherwise random offset chase
end

function RandomOffsetSimpleChaseBehavior:MonitorDistanceToTarget()
    Citizen.CreateThread(function()
        local target
        local target_position
        local actor_position
        local actor_target_distance
        local actor_ped

        while true do
            if not self.active then
                Wait(self.inactive_wait_time)
            elseif self.active then
                Wait(self.distance_check_cooldown)

                target = self.actor:GetTarget()
                actor_ped = self.actor:GetPed()

                if target then
                    target_position = target:GetPosition()
                    actor_position = self.actor:GetPosition()
                    actor_target_distance = Vector3Math:Distance(target_position, actor_position)

                    --print("actor_target_distance: ", actor_target_distance)

                    if self.offset_chasing then
                        if actor_target_distance < self.direct_chase_distance then
                            self.offset_chasing = false
                            self:ChaseTargetDirect()
                        end
                    elseif not self.offset_chasing then
                        if actor_target_distance > self.direct_chase_distance then
                            self.offset_chasing = true
                            self:ChaseTargetWithRandomOffset()
                        end
                    end
                end
            end
        end
    end)
end

function RandomOffsetSimpleChaseBehavior:ChaseTargetDirect()
    local actor_ped = self.actor:GetPed()
    local target = self.actor:GetTarget()

    if target then
        actor_ped:PermanentlyFollowEntity({
            other_entity = target:GetEntityId(),
            speed = 2.0 -- 0.5 for drunk zombie walk, 2.0 for run (from test code)
        })
        self:EnsureDistanceMonitoring()
    end

    print("Actor began direct chasing: ", closest_player)
end

-- need to test this?
function RandomOffsetSimpleChaseBehavior:ChaseTargetWithRandomOffset()
    local actor_ped = self.actor:GetPed()
    local target = self.actor:GetTarget()

    if target then
        --actor_ped:PermanentlyFollowEntity({
        --    other_entity = target:GetEntityId(),
        --    speed = 2.0 -- 0.5 for drunk zombie walk, 2.0 for run (from test code)
        --})
        math.randomseed(self.actor:GetPed().ped_id * 6 + actor_ped:GetPosition().x)
        TaskFollowToOffsetOfEntity(
            self.actor:GetPed().ped_id, -- ped: Ped id
            target:GetEntityId(), -- entity: Entity id
            math.random(20, 180) * (math.random() > .5 and -1 or 1) / 100,  -- offsetX: number
            math.random(20, 180) * (math.random() > .5 and -1 or 1) / 100, -- offsetY: number
            0.0, -- offsetZ: number
            2.0, -- movementSpeed: number
            -1, -- timeout: integer
            -1.0, -- stoppingRange: number
            true -- persistFollowing: boolean
        )
        self:EnsureDistanceMonitoring()
        print("Actor began random offset chasing: ", target)
    end
end

function RandomOffsetSimpleChaseBehavior:ChaseTarget()
    --if 1==1 then return end
    local target = self.actor:GetTarget()
    local actor_ped = self.actor:GetPed()

    if target then
        local target_position = target:GetPosition()
        local actor_position = self.actor:GetPosition()
        local actor_target_distance = Vector3Math:Distance(target_position, actor_position)

        self.active = true

        if actor_target_distance < self.direct_chase_distance then
            self.offset_chasing = false
            self:ChaseTargetDirect()
        elseif actor_target_distance >= self.direct_chase_distance then
            self.offset_chasing = true
            self:ChaseTargetWithRandomOffset()
        end
    end
end

function RandomOffsetSimpleChaseBehavior:EnsureDistanceMonitoring()
    if not self.monitoring then
        self.monitoring = true
        self:MonitorDistanceToTarget()
    end
end

function RandomOffsetSimpleChaseBehavior:GetDirectChaseDistance()
    return self.direct_chase_distance
end