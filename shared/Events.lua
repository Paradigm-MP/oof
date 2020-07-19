local Event = immediate_class()

local event_id = 0
function Event:__init(name, callback)
    self.name = name
    self.callback = callback
    self.id = event_id
    event_id = event_id + 1

    self.default_event = AddEventHandler(name, function(...)
        self:Fire(...)
    end)
end

function Event:Unsubscribe()
    Events:Unsubscribe(self.name, self.id)
    RemoveEventHandler(self.default_event)
end

function Event:Fire(...)
    return self.callback(...)
end

Events = immediate_class()

function Events:__init()
    self.subs = {}
end

function Events:Fire(event, ...)
    assert(event ~= nil and type(event) == "string", "cannot fire event without valid event")
    -- Nothing subscribed
    if not self.subs[event] then return {} end

    local return_vals = {}
    for id, cb in pairs(self.subs[event]) do
        local return_val = cb:Fire(...)
        if return_val ~= nil then
            table.insert(return_vals, return_val)
        end
    end
    return return_vals
end

function Events:Subscribe(name, callback)
    assert(name ~= nil, "cannot subscribe event without name")
    assert(type(callback) == "function", "cannot subscribe event without callback function")
    if not self.subs[name] then
        self.subs[name] = {}
    end

    local event = Event(name, callback)
    self.subs[name][event.id] = event

    return event
end

function Events:Unsubscribe(name, id)
    assert(self.subs[name] ~= nil and self.subs[name][id] ~= nil, "cannot unsubscribe event that does not exist")
    self.subs[name][id] = nil
    if count_table(self.subs[name]) == 0 then
        self.subs[name] = nil
    end
end

Events = Events()