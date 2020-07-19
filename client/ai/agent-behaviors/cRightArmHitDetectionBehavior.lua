RightArmHitDetectionBehavior = class()
RightArmHitDetectionBehavior.name = "RightArmHitDetectionBehavior"

function RightArmHitDetectionBehavior:BehaviorInitialize(actor)
    self.actor = actor
    
    self.active = false
    self.hit_detection_delay = 20

    self.debug_output_timer = Timer()
    Events:Subscribe("Render", function() self:RenderDebug() end)
end

-- start_time is the time after ActivateDetection that we should start detecting hits
function RightArmHitDetectionBehavior:ActivateDetection(start_time)
    if self.active then return end

    Citizen.CreateThreadNow(function()
        if start_time then
            Wait(start_time)
        end

        self.active = true
        self:DetectHits()
    end)
end

function RightArmHitDetectionBehavior:RenderDebug()
    --local actor_entity = self.actor:GetEntity()
    --local right_hand_pos = actor_entity:GetPedBonePositionPerformance(PedBoneEnum.RightHandMiddleFingerLastKnuckle)
    --local right_wrist_pos = actor_entity:GetPedBonePositionPerformance(PedBoneEnum.RightWrist)
    --local right_elbow_pos = actor_entity:GetPedBonePositionPerformance(PedBoneEnum.RightElbow)

    --local render_pos = vector3(right_hand_pos.x, right_hand_pos.y, right_hand_pos.z)
    --Render:DrawSphere(render_pos, .075, Colors.LawnGreen)
    --Render:DrawSphere(vector3(render_pos.x, render_pos.y, render_pos.z), .015, Colors.LawnGreen)

    --local pos = LocalPlayer:GetEntity():GetPedBonePositionPerformance(PedBoneEnum.Test)
    --Render:DrawSphere(vector3(pos.x, pos.y, pos.z), .015, Colors.LawnGreen)
    --Render:DrawSphere(vector3(pos.x, pos.y, pos.z), 0.045, Colors.LawnGreen)



    -- detection radius for PedBoneEnum.Spine3: .23
    -- detection radius for PedBoneEnum.Head: .135, and also offset .z +.03 of bone position


    --N_0x799017f9e3b10112(render_pos.x, render_pos.y, render_pos.z, 1.0, 255, 0, 0, 0.5)
    -- void _0x799017F9E3B10112(float x, float y, float z, float radius, int r, int g, int b, float opacity);
    if self.active then
        if self.debug_output_timer:GetMilliseconds() > self.hit_detection_delay then
            self.debug_output_timer:Restart()
            --print("right_hand_pos: ", right_hand_pos)
        end
    end
end

-- detects hits until Hibernate() is called
-- currently only works with single target behavior
function RightArmHitDetectionBehavior:DetectHits()
    Citizen.CreateThreadNow(function()
        local actor_entity = self.actor:GetEntity()
        local target_entity = self.actor:GetTarget():GetEntity()
        local can_reuse_actor_entity
        local can_reuse_target_entity

        -- actor bones we are checking
        local actor_middle_finger_bone_enum = PedBoneEnum.RightHandMiddleFingerLastKnuckle
        local actor_right_wrist_bone_enum   = PedBoneEnum.RightWrist
        local actor_right_elbow_bone_enum   = PedBoneEnum.RightElbow

        -- target bones we are checking as hit detection zones
        local target_head_bone_enum = PedBoneEnum.Head
        local target_spine3_bone_enum = PedBoneEnum.Spine3
        
        local actor_right_middle_finger_pos
        local actor_right_wrist_pos
        local actor_right_elbow_pos

        local target_head_pos
        local target_spine3_pos

        local hit_detected = function()
            --Chat:Print("Detected RightArm Hit!!!")
        end

        while self.active do
            -- performance critical code: re-use the Entity instance over the hit detection period
            -- we are removing the overhead from creating a new Entity instance each hit detection frame
            can_reuse_actor_entity = actor_entity:CanReuse()
            if not can_reuse_actor_entity then
                actor_entity = self.actor:GetEntity()
            end

            can_reuse_target_entity = target_entity:CanReuse()
            if not can_reuse_target_entity then
                target_entity = self.actor:GetTarget():GetEntity()
            end

            actor_right_middle_finger_pos = actor_entity:GetPedBonePositionPerformance(actor_middle_finger_bone_enum)
            actor_right_wrist_pos = actor_entity:GetPedBonePositionPerformance(actor_right_wrist_bone_enum)
            actor_right_elbow_pos = actor_entity:GetPedBonePositionPerformance(actor_right_elbow_bone_enum)

            target_head_pos = target_entity:GetPedBonePositionPerformance(target_head_bone_enum)
            target_spine3_pos = target_entity:GetPedBonePositionPerformance(target_spine3_bone_enum)

            -- test head
            dist = Vector3Math:Distance(actor_right_middle_finger_pos, target_head_pos)
            if dist < 0.135 then hit_detected() end

            dist = Vector3Math:Distance(actor_right_wrist_pos, target_head_pos)
            if dist < 0.135 then hit_detected() end

            dist = Vector3Math:Distance(actor_right_elbow_pos, target_head_pos)
            if dist < 0.135 then hit_detected() end

            -- test spine
            dist = Vector3Math:Distance(actor_right_middle_finger_pos, target_spine3_pos)
            if dist < 0.23 then hit_detected() end

            dist = Vector3Math:Distance(actor_right_wrist_pos, target_spine3_pos)
            if dist < 0.23 then hit_detected() end

            dist = Vector3Math:Distance(actor_right_elbow_pos, target_spine3_pos)
            if dist < 0.23 then hit_detected() end


            --local right_hand_pos = actor_entity:GetPedBonePositionPerformance(PedBoneEnum.RightHandMiddleFingerLastKnuckle)
            --local right_wrist_pos = actor_entity:GetPedBonePositionPerformance(PedBoneEnum.RightWrist)
            --local right_elbow_pos = actor_entity:GetPedBonePositionPerformance(PedBoneEnum.RightElbow)

            --print("DETECTING HITS")
            --local right_hand_pos = actor_entity:GetPedBonePositionPerformance(PedBoneEnum.RightHand)
            --print("right_hand_pos: ", right_hand_pos)
            



            Wait(self.hit_detection_delay)
        end
    end)
end

function RightArmHitDetectionBehavior:Hibernate()
    self.active = false
end

