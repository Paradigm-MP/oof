function distance(a, b)
    local type = type(a)

    if is_class_instance(a, Entity) then
        return #(a:GetPosition() - b:GetPosition())
    elseif type == "vector3" then
        -- easier code translation > function call overhead concern
        return Vector3Math:Distance(a, b)
    end
end