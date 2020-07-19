ZombiePunchBehavior = class()
ZombiePunchBehavior.name = "ZombiePunchBehavior" -- static variable example
--[[
    ZombiePunchBehavior: throws punches at Actor's target using Actor:GetTarget()
    * compatible with single target behaviors
]]

function ZombiePunchBehavior:BehaviorInitialize(actor)
    self.actor = actor

    -- Turning config
    self.turning = false
    self.turn_cooldown_timer = Timer()
    self.active = true
    self.turn_check_delay_max = 800
    self.turn_check_delay_min = 300
    self.turn_distance_threshold = 1.75 -- threshold in meters
    self.turn_cooldown_time = 2 -- cooldown in seconds
    self.turn_check_delay = self.turn_check_delay_min

    -- Punching config
    self.punch_animation_dictionary = "melee@unarmed@streamed_variations"
    self.punch_animation_name = "plyr_takedown_front_slap"
    self.punch_range = 1.2 -- m
    self.punch_check_cooldown = 100 -- ms
    self.punch_time = 825
    self.punch_cooldown_timer = Timer()
    self.punch_cooldown = 2.5 -- s
    self.punch_heading_threshold = 25 -- degrees

    -- debug
    self.punched_count = 0

    self:PunchCheck()
end

-- check if the Actor's target is within punching range
function ZombiePunchBehavior:PunchCheck()
    Citizen.CreateThread(function()
        local target
        local target_position
        local actor_position
        local actor_target_distance

        while self.active do
            Wait(self.punch_check_cooldown)

            if self.punch_cooldown_timer:GetSeconds() > self.punch_cooldown then
                target = self.actor:GetTarget()
                if target then
                    target_position = target:GetPosition()
                    actor_position = self.actor:GetPosition()
                    actor_target_distance = Vector3Math:Distance(target_position, actor_position)

                    --print("actor_target_distance: ", actor_target_distance)
                    
                    if actor_target_distance < self.punch_range then -- and self.turn_cooldown_timer:GetSeconds() > self.turn_cooldown_time then
                        local actor_entity = self.actor:GetEntity()
                        local heading_delta = actor_entity:GetDeltaHeadingTowardsEntity(target:GetEntityId())

                        --print("heading_delta: ", heading_delta)
                        
                        if heading_delta < self.punch_heading_threshold then
                            self.punch_cooldown_timer:Restart()
                            
                            self.actor:FireBehaviorEvent("PrePunch")
                            self:Punch(target) -- non-blocking

                            local timer = Timer()
                            local starting_velocity = self.actor:GetEntity():GetVelocity()
                            local can_reuse_entity

                            while timer:GetMilliseconds() < self.punch_time do
                                can_reuse_entity = actor_entity:CanReuse()
                                if not can_reuse_entity then
                                    actor_entity = self.actor:GetEntity()
                                end

                                self.actor:GetEntity():SetVelocity(starting_velocity)
                                Wait(1)
                            end
                            --Wait(1500)

                            --Chat:Print("PostPunch")
                            self.actor:FireBehaviorEvent("PostPunch")
                        end
                    end
                end
            end
        end
    end)
end

function ZombiePunchBehavior:Punch(target)
    local actor_entity = self.actor:GetEntity()
    local actor_ped = self.actor:GetPed()
    local target_ped = target:GetPed()
     
    actor_ped:PlayAnim({
        animDict = self.punch_animation_dictionary, --punch #1
        animName = self.punch_animation_name,
        --animDict = "melee@unarmed@streamed_stealth", -- punch #4
        --animName = "plyr_stealth_kill_unarmed_hook_r",
        --animDict = "melee@unarmed@streamed_core",
        --animName = "walking_punch_no_target",
        position = self.actor:GetPosition(),
        animTime = 0.00, -- (float 0-1) lets you start the animation from a given point
        duration = 250,
        flag = 16
    })

    -- melee@unarmed@streamed_core
    -- walking_punch_no_target

    self.punched_count = self.punched_count + 1
    --print("PUNCH ", self.punched_count)
end







function ZombiePunchBehavior:PunchCheckDEPRECATED()
    Citizen.CreateThread(function()
        local target
        local target_position
        local actor_position
        local actor_target_distance

        while self.active do
            Wait(self.turn_check_delay)

            target = self.actor:GetTarget()

            if target then -- debug, remove this
                target_position = target:GetPosition()
                actor_position = self.actor:GetPosition()
                actor_target_distance = #(target_position - actor_position)

                --print("actor_target_distance: ", actor_target_distance)
                if actor_target_distance < self.turn_distance_threshold then -- and self.turn_cooldown_timer:GetSeconds() > self.turn_cooldown_time then
                    --print("self.turning: ", self.turning)
                    if not self.turning then
                        self.turning = true
                        self.turn_cooldown_timer:Restart()
                        --self:TurnToTarget(target, actor_position) -- pauses thread execution
                        self.turning = false
                    end
                end
                --print("actor_target_distance: ", actor_target_distance)
            end
        
        end
    end)
end

function ZombiePunchBehavior:TurnToTarget(target, initial_actor_position)
    local actor_entity = self.actor:GetEntity()
    local ped = self.actor:GetPed()
    local target_ped = target:GetPed()
    local target_entity = target:GetEntity()

    local initial_actor_heading = actor_entity:GetYaw()
    local ideal_punch_heading = actor_entity:GetHeadingTowardsEntity(target_entity)


    local current_heading_offset = ideal_punch_heading - initial_actor_heading
    
    --[[ current_heading_offset - 0 / 360 is where the NPC is facing
              0 / 360
                 -
           1     -    4
                 -
      90  ---------------  270
                 -
            2    -    3
                 -
                180
    ]]

    if current_heading_offset < 0 then
        current_heading_offset = current_heading_offset + 360
    end

    --print("initial current heading offset: ", current_heading_offset)

    if current_heading_offset >= 5 and current_heading_offset <= 90 then
        -- 1
        self:ExecuteTurn(ped, actor_entity, target_entity, target_ped, "move_m@drunk@moderatedrunk", "idle_turn_l_-90") -- left 90 deg turn
    elseif current_heading_offset > 90 and current_heading_offset <= 180 then
        -- play 180 turn, turning to the left
        -- 2
        self:ExecuteTurn(ped, actor_entity, target_entity, target_ped, "move_m@drunk@moderatedrunk", "idle_turn_l_-180") -- left 180 deg turn
    elseif current_heading_offset > 180 and current_heading_offset <= 270 then
        -- 3
        -- play 180 turn, turning to the right
        self:ExecuteTurn(ped, actor_entity, target_entity, target_ped, "move_m@drunk@moderatedrunk", "idle_turn_r_-180") -- right 180 deg turn
    elseif current_heading_offset > 270 and current_heading_offset <= 360 then
        -- 4
        self:ExecuteTurn(ped, actor_entity, target_entity, target_ped, "move_m@drunk@moderatedrunk", "idle_turn_r_90") -- right 90 deg turn
    end

    self.turning = false
end

function ZombiePunchBehavior:ExecuteTurn(actor_ped, actor_entity, target_entity, target_ped, anim_dict, anim_name)
    -- play left 90 degree turn
    actor_ped:PlayAnim({
        animDict = anim_dict,
        animName = anim_name,
        --playbackRate = 
        animTime = 0.155 -- (float 0-1) lets you start the animation from a given point
    })

    for i = 1, 40 do
        Wait(65)
        ideal_punch_heading = actor_entity:GetHeadingTowardsEntity(target_entity)
        local actor_heading = actor_entity:GetYaw()

        --print("ideal_punch_heading: ", ideal_punch_heading) -- should remain roughly constant
        --print("actor_heading: ", actor_heading)

        current_heading_offset = ideal_punch_heading - actor_heading
        --Render:DrawLine()
        --print("current_heading_offfset: ", current_heading_offset)
    
        if current_heading_offset < 10 then
            StopEntityAnim(actor_entity:GetEntityId(), turn_anim, turn_dict, 0)
            --print("Stopped anim because facing Player")

            --actor_entity:SetHeading(actor_heading) -- stop dat animation
        

            if distance(actor_entity, target_entity) < self.punch_range then
                self:Punch()
            end

            self.turning = false
            break
        end
    end
    self.turning = false
end
