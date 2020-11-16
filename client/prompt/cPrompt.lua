if IsRedM then

Prompt = class()

--[[
    Creates a new UI prompt.

    args (in table):
        text (string): text to display
        position (vector3) (optional): position to trigger the prompt at
        size (number): size of prompt trigger zone
        control (Control enum): control to trigger this prompt

]]
function Prompt:__init(args)
    self.str = CreateVarString(10, "LITERAL_STRING", args.text)
    self.position = args.position
    self.size = tofloat(args.size)
    self.control = args.control

    self:Create()
    self:SetEnabled(true)
    self:SetVisible(true)
    self:SetContextPoint(self.position)
    self:SetContextSize(self.size)

    Events:Subscribe("onResourceStop", self, self.OnResourceStop)
end

function Prompt:Create()
    self.prompt = Citizen.InvokeNative(0x29FA7910726C3889, self.control, self.str, 6, 1, 1, -1, Citizen.ResultAsInteger())
end

function Prompt:SetEnabled(enabled)
    Citizen.InvokeNative(0x8A0FB4D03A630D21, self.prompt, enabled)
end

function Prompt:SetVisible(visible)
    Citizen.InvokeNative(0x71215ACCFDE075EE, self.prompt, visible)
end

function Prompt:SetHoldMode(seconds_to_hold)
    Citizen.InvokeNative(0x74C7D7B72ED0D3CF, self.prompt, seconds_to_hold)
end

function Prompt:HasHoldModeCompleted()
    return Citizen.InvokeNative(0xE0F65F0640EF0617, self.prompt)
end

function Prompt:SetHoldIndefinitelyMode()
    Citizen.InvokeNative(0xEA5CCF4EEB2F82D1, self.prompt)
end

function Prompt:SetContextPoint(pos)
    self.position = pos
    Citizen.InvokeNative(0xAE84C5EE2C384FB3, self.prompt, self.position.x, self.position.y, self.position.z)
end

function Prompt:IsHoldModeRunning()
    return Citizen.InvokeNative(0xC7D70EAEF92EFF48, self.prompt)
end

function Prompt:IsPressed()
    return Citizen.InvokeNative(0x21E60E230086697F, self.prompt)
end

function Prompt:SetContextSize(size)
    self.size = size
    Citizen.InvokeNative(0x0C718001B77CA468, self.prompt, size)
end

function Prompt:OnResourceStop(name)
    if name == GetCurrentResourceName() then
        self:Remove()
    end
end

function Prompt:Remove()
    Citizen.InvokeNative(0x00EDE88D4D13CF59, self.prompt)
end

end