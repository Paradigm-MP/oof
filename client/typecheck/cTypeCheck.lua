TypeCheck = class()


function TypeCheck:Number(n)
    assert(type(n) == "number", "arg expected to be a number")
end

function TypeCheck:Position(pos)
    assert(type(pos) == "vector2", "position expected to be a vector2")
end

function TypeCheck:Position3D(pos)
    assert(type(pos) == "vector3", "position3d expected to be a vector3")
end

function TypeCheck:Text(text)
    assert(type(text) == "string", "text expected to be a string")
    return text
end

function TypeCheck:Color(color)
    assert(is_class_instance(color, Color), "color expected to be a Color")
    assert(color.r ~= nil and color.g ~= nil and color.b ~= nil and color.a ~= nil, "color missing a component")
end

function TypeCheck:Font(font)
    font = math.round(font)
    assert(type(font) == "number" and font >= 0 and font < 5, "font expected to be a number 0-4")
end

function TypeCheck:Scale(scale)
    assert(type(scale) == "table", "scale expected to be a table")
    assert(scale.x ~= nil and scale.y ~= nil, "scale missing a component")
end

function TypeCheck:Size(size)
    assert(type(size) == "table", "size expected to be a table")
    assert(size.x ~= nil and size.y ~= nil, "size missing a component")
end

TypeCheck = TypeCheck()