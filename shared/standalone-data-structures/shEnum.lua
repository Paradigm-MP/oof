-- the base Enum class
Enum = class()

function Enum:EnumInit()
    self.descriptions = {}
end

function Enum:SetDescription(index, description)
    self.descriptions[index] = description
end

function Enum:GetDescription(index)
    if self.descriptions[index] then
        return self.descriptions[index]
    else
        error("Tried to get Enum description but description does not exist")
    end
end
