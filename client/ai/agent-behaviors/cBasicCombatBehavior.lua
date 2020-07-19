BasicCombatBehavior = class()
BasicCombatBehavior.name = "BasicCombatBehavior"
--[[
    BasicCombatBehavior:
]]

function BasicCombatBehavior:BehaviorInitialize(actor)
    self.actor = actor

    Events:Subscribe("NewRound", function(args) self:NewRound() end)
end

function BasicCombatBehavior:NewRound(args)
    --print("NewRound in BasicCombatBehavior")
end