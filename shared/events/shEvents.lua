Events = class()

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

function Events:Subscribe(name, instance, callback)
    assert(name ~= nil, "cannot subscribe event without name")
    if type(instance) ~= "function" and type(instance) ~= "table" then
        error("callback function non-existant or no callback instance provided. Function usage is Events:Subscribe(name, instance, callback) or Events:Subscribe(name, callback)")
    end

    if not self.subs[name] then
        self.subs[name] = {}
    end

    local event = Event(name, instance, callback)
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
