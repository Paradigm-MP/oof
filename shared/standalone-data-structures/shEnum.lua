-- the base Enum class from which all other enums are children of
Enum = immediate_class()

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
