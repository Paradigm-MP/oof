Light = class()

LightIds = 0 -- Track light ids

function GenerateLightId()
    LightIds = LightIds + 1
    return LightIds
end

--[[
    Creates a light.

    args (in table):

    position - (vector3) position
    color - (Color) the color of the light
    type - (string) can be either LightTypes.Spot or LightTypes.Point
    shadow - (bool) whether or not this light creates shadows

    args required for LightTypes.Spot:
        direction - (vector3) which way the light is pointing
            very finicky - if you have a 0 as the z component it may not work
        brightness - (number) how bright it is
        hardness - (number) how hard the edges of the light are
        radius - (number) how wide the radius is
        falloff - (number) how much the light fades with distance

    args required for LightTypes.Point:
        range - (number) range of the light
        intensity - (number) how bright/intense the light is

]]
function Light:__init(args)

    assert(args.type == LightTypes.Point and args.shadow == false, 
        "Unsupported light type (currently). Try LightTypes.Point and shadow = false")

    assert(type(args.position) == "vector3", "args.position expected to be a vector3")
    TypeCheck:Color(args.color)
    assert(args.type == LightTypes.Spot or args.type == LightTypes.Point, "args.type expected to be a LightTypes")

    self.position = args.position
    self.color = args.color
    self.type = args.type
    self.shadow = args.shadow
    self.id = GenerateLightId()

    if self.type == LightTypes.Spot then
        assert(type(args.direction) == "vector3", "args.direction expected to be a vector3")
        TypeCheck:Number(args.distance)
        TypeCheck:Number(args.brightness)
        TypeCheck:Number(args.hardness)
        TypeCheck:Number(args.radius)
        TypeCheck:Number(args.falloff)

        self.direction = tofloat(args.direction)
        self.distance = tofloat(args.distance)
        self.brightness = tofloat(args.brightness)
        self.hardness = tofloat(args.hardness)
        self.radius = tofloat(args.radius)
        self.falloff = tofloat(args.falloff)
    else
        TypeCheck:Number(args.range)
        TypeCheck:Number(args.intensity)

        self.range = tofloat(args.range)
        self.intensity = tofloat(args.intensity)
    end

    self.enabled = true

    self:Draw()

end

function Light:GetPosition()
    return self.position
end

function Light:SetPosition(pos)
    assert(type(pos) == "vector3", "pos expected to be a vector3")
    self.position = pos
end

function Light:GetColor()
    return self.color
end

function Light:SetColor(col)
    TypeCheck:Color(col)
    self.color = col
end

function Light:SetDirection(dir)
    assert(type(dir) == "vector3", "direction expected to be a vector3")
    self.direction = dir
end

function Light:GetDirection()
    return self.direction
end

function Light:GetBrightness()
    return self.brightness
end

function Light:SetBrightness(b)
    TypeCheck:Number(b)
    self.brightness = b
end

function Light:GetHardness()
    return self.hardness
end

function Light:SetHardness(h)
    TypeCheck:Number(h)
    self.hardness = h
end

function Light:GetRadius()
    return self.radius
end

function Light:SetRadius(radius)
    TypeCheck:Number(radius)
    self.radius = radius
end

function Light:SetFalloff(falloff)
    TypeCheck:Number(falloff)
    self.falloff = falloff
end

function Light:GetFalloff()
    return self.falloff
end

function Light:GetRange()
    return self.range
end

function Light:SetRange(range)
    TypeCheck:Number(range)
    self.range = range
end

function Light:GetIntensity()
    return self.intensity
end

function Light:SetIntensity(intensity)
    TypeCheck:Number(intensity)
    self.intensity = intensity
end

function Light:SetEnabled(enabled)
    assert(type(enabled) == "bool", "enabled expected to be a bool")
    self.enabled = enabled
    if self.enabled then
        self:Draw() -- Draw call to remake coroutine
    end
end

function Light:GetShadowEnabled()
    return self.shadow
end

function Light:SetShadowEnabled(shadow)
    assert(type(shadow) == "bool", "shadow expected to be a bool")
    self.shadow = shadow
end

function Light:Draw()
    local type = self.type
    local id = self.id

    CreateThread(function()
        while self.enabled do

            Wait(1)
            
            if type == LightTypes.Spot then
                if self.shadow then
                    DrawSpotLightWithShadow(
                        self.position.x, self.position.y, self.position.z,
                        self.direction.x, self.direction.y, self.direction.z,
                        self.color.r, self.color.g, self.color.b,
                        self.distance, self.brightness, self.hardness,
                        self.radius, self.falloff, self.id
                    )
                else
                    DrawSpotLight(
                        self.position.x, self.position.y, self.position.z,
                        self.direction.x, self.direction.y, self.direction.z,
                        self.color.r, self.color.g, self.color.b,
                        self.distance, self.brightness, self.hardness,
                        self.radius, self.falloff
                    )
                end
            else
                if self.shadow then
                    DrawLightWithRangeAndShadow(
                        self.position.x, self.position.y, self.position.z,
                        self.color.r, self.color.g, self.color.b,
                        self.range, self.intensity, self.id
                    )
                else
                    DrawLightWithRange(
                        self.position.x, self.position.y, self.position.z,
                        self.color.r, self.color.g, self.color.b,
                        self.range, self.intensity
                    )
                end
            end
        end
    end)
end

function Light:Remove()
    self.enabled = false
end

LightTypes = {Spot = 1, Point = 2}