-- immediate class is a class that immediately comes into existance, even before __loadFirst is executed
-- the point of immediate classes is to make sure __loadFirst functions can use these classes
-- do not make a Model (like Player, Entity, or Actor) an immediate_class
-- try not to use immediate_class's
local NetworkEvent = immediate_class()

local NetworkEvent_id = 0
function NetworkEvent:__init(name, callback)
    self.name = name
    self.callback = callback
    self.id = NetworkEvent_id
    NetworkEvent_id = NetworkEvent_id + 1
end

function NetworkEvent:Unsubscribe()
    Network:Unsubscribe(self.name, self.id)
end

function NetworkEvent:Receive(source, args)
    -- source is nil if this is clientside, otherwise it is the player who sent it
    local return_args = {source = source, player = sPlayers:GetById(source)}

    if args then 
        for k,v in pairs(args) do 
            return_args[k] = v 
        end 
    end
    
    self.callback(return_args)
end

Network = immediate_class()

function Network:__init()
    self.subs = {}
    self.handlers = {}

end

function Network:Send(name, players, args)
    assert(name ~= nil and type(name) == "string", "cannot Network:Send without valid networkevent")

    assert(type(players) == "number" or type(players) == "table" or type(players) == "Player", 
        "cannot Network:Send without valid player id(s). Specify -1 for all, one id, or a table")
    
    if type(players) == "number" then
        TriggerClientEvent(name, players, args)
    elseif type(players) == "Player" then
        TriggerClientEvent(name, players:GetId(), args)
    elseif type(players) == "table" then
        for _, id in pairs(players) do
            TriggerClientEvent(name, id, args)
        end
    end
end

function Network:Broadcast(name, args)
    self:Send(name, -1, args)
end

--[[
    Subscribe to a network event.

    Example usage:
    Network:Subscribe("PlayerLoaded", function(args)
    end)
]]
function Network:Subscribe(name, callback)
    assert(name ~= nil, "cannot subscribe networkevent without name")
    assert(type(callback) == "function", "cannot subscribe Network without callback function")

    if not self.subs[name] then
        self.subs[name] = {}
        RegisterNetEvent(name)
        self.handlers[name] = AddEventHandler(name, function(args)
            for _, networkevent in pairs(self.subs[name]) do
                networkevent:Receive(source, args)
            end
        end)
    end

    local networkevent = NetworkEvent(name, callback)
    self.subs[name][networkevent.id] = networkevent

    return networkevent
end

function Network:Unsubscribe(name, id)
    assert(name ~= nil, "cannot unsubscribe networkevent without name")

    assert(self.subs[name] ~= nil and self.subs[name][id] ~= nil, "cannot unsubscribe NetworkEvent that does not exist")
    self.subs[name][id] = nil

    if count_table(self.subs[name]) == 0 then
        RemoveEventHandler(self.handlers[name])
        self.subs[name] = nil
        self.handlers[name] = nil
    end
end

Network = Network()