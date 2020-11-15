local NetworkEvent = class()

local NetworkEvent_id = 0
function NetworkEvent:__init(name, instance, callback)
    self.name = name
    self.instance = instance
    self.callback = callback
    self.id = NetworkEvent_id
    NetworkEvent_id = NetworkEvent_id + 1
end

function NetworkEvent:Unsubscribe()
    Network:Unsubscribe(self.name, self.id)
end

function NetworkEvent:Receive(args, name)
    -- source is nil if this is clientside, otherwise it is the player who sent it
    local return_args = {}
    local is_fetch = false
    local fetch_id

    if args then
        is_fetch = args.__is_fetch
        fetch_id = args.__fetch_id
        args.__is_fetch = nil
        args.__fetch_id = nil
        for k,v in pairs(args) do 
            return_args[k] = v
        end 
    end
    
    local return_value
    if self.callback then
        return_value = self.callback(self.instance, return_args)
    else
        local callback = self.instance
        return_value = callback(return_args)
    end

    if is_fetch then
        assert(return_value and type(return_value) == "table", "A Network:Fetch handler function must return a table!")
        Network:Send(name .. "__FetchCallback" .. tostring(fetch_id), return_value)
    end
end

Network = class()

function Network:__init()
    self.subs = {}
    self.handlers = {}
    self.current_fetch_id = 1
    self.fetch_data = {}
end

function Network:Send(name, args)
    assert(name ~= nil and type(name) == "string", "cannot Network:Send without valid networkevent")

    TriggerServerEvent(name, args)
end

--[[
    Blocks the current Thread until a response is received from the server
]]
function Network:Fetch(name, args)
    self.current_fetch_id = self.current_fetch_id + 1
    local fetch_id = self.current_fetch_id
    local fetch_args = args
    if not args then
        fetch_args = {}
    end
    fetch_args.__is_fetch = true
    fetch_args.__fetch_id = fetch_id
    Network:Send(name, fetch_args)
    fetch_args.__is_fetch = nil
    fetch_args.__fetch_id = nil

    local subscription = Network:Subscribe(name .. "__FetchCallback" .. tostring(fetch_id), function(args)
        self.fetch_data[fetch_id] = args
    end)


    local response_timer = Timer()
    local fetched_data
    while not self.fetch_data[fetch_id] do
        Wait(10)
        if response_timer:GetSeconds() > 4 then
            print("Network:Fetch timed out! No response received from the server within 4 seconds. Did you forget to add a Network:Subscribe for this Fetch in the server-side code?")
            break
        end
    end
    fetched_data = self.fetch_data[fetch_id]
    self.fetch_data[fetch_id] = nil
    subscription:Unsubscribe()

    return fetched_data
end

--[[
    Subscribe to a network event.

    Example usage:
    Network:Subscribe("PlayerLoaded", function(args)
    end)
]]
function Network:Subscribe(name, instance, callback)
    assert(name ~= nil, "cannot subscribe networkevent without name")
    assert(type(instance) == "table" or type(instance) == "function", "callback function non-existant or no callback instance provided. Function usage is Network:Subscribe(name, instance, callback) or Network:Subscribe(name, callback)")

    if not self.subs[name] then
        self.subs[name] = {}

        RegisterNetEvent(name)
        self.handlers[name] = AddEventHandler(name, function(args)
            for _, networkevent in pairs(self.subs[name]) do
                networkevent:Receive(args, name)
            end
        end)
    end

    local networkevent = NetworkEvent(name, instance, callback)
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