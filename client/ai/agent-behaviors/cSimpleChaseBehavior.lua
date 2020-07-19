SimpleChaseBehavior = class()
SimpleChaseBehavior.name = "SimpleChaseBehavior"
--[[
    SimpleChaseBehavior: sets the task for the Ped to follow some entity using self.target
    * compatible with single target behaviors
]]

function SimpleChaseBehavior:BehaviorInitialize(actor)
    self.actor = actor
end

function SimpleChaseBehavior:ChaseTarget()
    local actor_ped = self.actor:GetPed()
    local target = self.actor:GetTarget()

    if target then
        actor_ped:PermanentlyFollowEntity({
            other_entity = target:GetEntityId(),
            speed = 0.5 -- 0.5 for drunk zombie walk, 2.0 for run (from test code)
        })
    end
    print("Actor began chasing: ", closest_player)
end