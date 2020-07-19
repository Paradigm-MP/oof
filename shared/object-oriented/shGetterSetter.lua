-- an addition to the object-oriented structure that adds a getter and setter to a class
-- adds instance:GetVariableName and instance:SetVariableName to a class instance
function getter_setter(instance, get_set_name)
    local function firstCharacterToUpper(str)
        return (str:gsub("^%l", string.upper))
    end

    local name = ""
    local words = split(get_set_name, "_")
    for k, word in ipairs(words) do
        name = name .. firstCharacterToUpper(word)
    end

    local get_name = "Get" .. name
    local set_name = "Set" .. name

    instance[get_name] = function()
        return instance[get_set_name]
    end
    
    instance[set_name] = function(instance, value)
        instance[get_set_name] = value
    end
end


-- adds instance:GetVariableName and instance:SetVariableName to a class instance, and encrypts the value in memory
-- to access or modify this value, it is required to exclusively use the Get and Set functions so that the value can be encrypted and decrypted properly
-- currently works with strings and numbers
function getter_setter_encrypted(instance, get_set_name)
    local function firstCharacterToUpper(str)
        return (str:gsub("^%l", string.upper))
    end

    local name = ""
    local words = split(get_set_name, "_")
    for k, word in ipairs(words) do
        name = name .. firstCharacterToUpper(word)
    end

    local get_name = "Get" .. name
    local set_name = "Set" .. name

    instance[get_name] = function()
        return xor_decrypt(instance[get_set_name])
    end
    
    instance[set_name] = function(instance, value)
        instance[get_set_name] = xor_encrypt(value)
    end
end