UIInstance = class()

function UIInstance:__init(args)
    self.name = args.name
    self.path = args.path
    self.css = args.css
    self.visible = args.visible or true
end

--[[
    Subscribe to UI events!
]]
function UIInstance:Subscribe(event_name, instance, callback)
    RegisterNUICallback(string.format("%s_%s", self.name, event_name), function(args)
        -- Use a thread to get proper callstack on future errors
        Citizen.CreateThread(function()
            if not callback then
                instance(args)
            else
                callback(instance, args)
            end
        end)
    end)
end

function UIInstance:BringToFront()
    SendNUIMessage({nui_event = "ui/bring_to_front", name = self.name})
end

function UIInstance:SendToBack()
    SendNUIMessage({nui_event = "ui/send_to_back", name = self.name})
end

--[[
    Calls an event on a specific UI instance.

    data - (table) table of data you want to send with the event
]]
function UIInstance:CallEvent(event_name, data)
    assert(type(event_name) == "string", "event_name expected to be a string")
    if not data then data = {} end
    data.nui_event = event_name
    -- data = EnsureStringKeys(data)
    SendNUIMessage({nui_event = "ui/event", name = self.name, data = data})
end

-- Loops through all tables in a table and converts keys to strings if they are not already
function EnsureStringKeys(input)
    if type(input) == "table" then
        local input_string_keys = {}
        for key, value in pairs(input) do
            input_string_keys[tostring(key)] = EnsureStringKeys(value)
        end
        return input_string_keys
    end
    return input
end

--[[
    If the UI is visible or not
]]
function UIInstance:GetVisible()
    return self.visible
end

--[[
    Hides the UI instance.
]]
function UIInstance:Hide()
    SendNUIMessage({nui_event = "ui/hide", name = self.name})
    self.visible = false
end

--[[
    Shows the UI instance.
]]
function UIInstance:Show()
    SendNUIMessage({nui_event = "ui/show", name = self.name})
    self.visible = true
end

--[[
    Removes a UI instance
]]
function UIInstance:Remove()
    UI:Remove(self.name)
end

-- --------------------------------------------------

UI = class()

function UI:__init()
    self.uis = {}

    -- ref count nui focus/cursor
    self.ref = {focus = 0, cursor = 0}
    self.size = {x = 0, y = 0}

    self.ui_ready = false
    RegisterNUICallback("ui/ready", function(args)
        self.ui_ready = true
        self.size.x = args.size.x
        self.size.y = args.size.y
    end)
    
    --[[ In order to use this event, please make sure to have these two lines in your code:
        UI:KeepInput(true)
        UI:SetFocus(true)

        This will ensure that the UI picks up keypresses even when not visible
    --]]
    RegisterNUICallback("ui/keypress", function(args)
        Events:Fire("UIKeyPress", args)
    end)

    self:SetNuiFocus()

    SendNUIMessage({nui_event = "ui/lua_ready"})
end

function UI:KeepInput(keep_input)
    SetNuiFocusKeepInput(keep_input)
end

function UI:GetSize()
    return self.size
end

function UI:SetCursor(enabled)
    self.ref.cursor = math.max(0, enabled and self.ref.cursor + 1 or self.ref.cursor - 1)
    self:SetNuiFocus()
end

function UI:SetFocus(enabled)
    self.ref.focus = math.max(0, enabled and self.ref.focus + 1 or self.ref.focus - 1)
    self:SetNuiFocus()
end

function UI:GetFocus()
    return self.ref.focus
end

function UI:GetCursor()
    return self.ref.cursor
end

function UI:SetNuiFocus()
    SetNuiFocus(self.ref.focus > 0, self.ref.cursor > 0)
end

--[[
    Creates a new UIInstance.

    args: (in table)

    name - (string) name of ui instance. Must be unique.
    path - (string) path to html page. Must be relative to resource, eg: lobby/client/html/index.html
]]
function UI:Create(args)
    assert(type(args.name) == "string", "name must be a string")
    assert(type(args.path) == "string", "path must be a string")

    local ui = UIInstance(args)

    Citizen.CreateThread(function()
        while not self.ui_ready do
            Wait(100)
        end
        SendNUIMessage({
            nui_event = "ui/create", 
            name = args.name,
            path = args.path,
            css = args.css or {},
            visible = not (args.visible == false)
        })
    end)

    self.uis[args.name] = ui
    return ui
end

--[[
    Calls an event on a single or all UI instances.

    args: (in table)
    data - (table) the table of data you want to send
    event_name - (string) event name
    name (optional) - name of the UI instance you want to send to, nil for all
]]
function UI:CallEvent(args)
    if args.name and self.uis[args.name] then
        self.uis[args.name]:CallEvent(args.event_name, args.data)
    else
        for name, ui in pairs(self.uis) do
            ui:CallEvent(args.event_name, args.data)
        end
    end
end

--[[
    Removes a UI instance by name
]]
function UI:Remove(name)
    if self.uis[name] then
        SendNUIMessage({nui_event = "ui/remove", name = name})
        self.uis[name] = nil
    end
end

UI = UI()
