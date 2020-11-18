local OgLuaTostring = tostring
function tostring(variable)
    if type(variable) == "table" and variable.__class_instance then
        return variable:tostring()
    else
        return OgLuaTostring(variable)
    end
end