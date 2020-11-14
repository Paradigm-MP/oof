Event = class()

local event_id = 0
function Event:__init(name, instance, callback)
    self.name = name
    self.instance = instance
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
    if self.callback then
        return self.callback(self.instance, ...)
    else
        local callback = self.instance
        return callback(...)
    end
end