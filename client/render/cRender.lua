Render = class()

function Render:__init()
    self:RenderEvent()
end

function Render:RenderEvent()
    Citizen.CreateThread(function()
        while true do
            Events:Fire("Render")
            Citizen.Wait(0)
        end
    end)
end

Justification = {
    Center = 0,
    Left = 1,
    Right = 2
}
--[[
    Sets text justification.
]]
function Render:SetTextJustification(jus)
    assert(jus == Justification.Center or jus == Justification.Left or jus == Justification.Right, "invalid justification value")
    SetTextJustification(jus)
end

--[[
    Resets text alignment set by Render:SetAlignment
]]
function Render:ResetAlignment()
    ResetScriptGfxAlign()
end


GfxAlign = {
    Horizontal = {
        Center = 67,
        Left = 76,
        Right = 82
    },
    Vertical = {
        Center = 67,
        Bottom = 66,
        Top = 84
    }
}
--[[
    Sets the alignment of rendered text. This sets the origin, so Center,Center would be vector2(0,0) at the center of the screen

    h - horizontal alignment
    v - vertical alignment

    If anything but valid args are used, nothing happens
]]
function Render:SetAlignment(h, v)
    TypeCheck:Number(h)
    TypeCheck:Number(v)
    SetScriptGfxAlign(h, v)
end

--[[
    Converts a world position to a screen position

    pos - vector3

    returns vector2 and bool if it is on screen or not
]]
function Render:WorldToScreen(pos)
    TypeCheck:Position3D(pos)
    local on_screen, x, y = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
    return vector2(x,y), on_screen
end

--[[
    Converts a world position to a hud position (bounded to screen)

    pos - vector3

    returns vector2 and bool if it is on screen or not
]]
function Render:WorldToHud(pos)
    TypeCheck:Position3D(pos)
    local _, x, y = GetHudScreenPositionFromWorldPosition(pos.x, pos.y, pos.z)
    return vector2(x,y)
end

--[[
    Draws a 3D sphere in the world

    pos - table of x,y,z 
    radius - number
    color - table of rgba values (or Color class) (alpha is 0-1)
]]
function Render:DrawSphere(pos, radius, color)
    TypeCheck:Position3D(pos)
    TypeCheck:Number(radius)
    TypeCheck:Color(color)

    N_0x799017f9e3b10112(pos.x, pos.y, pos.z, radius, color.r, color.g, color.b, color.a_percentage_float)
end


HighlightCoordsColors = 
{
    Red = 0,
    Green = 1,
    Blue = 2,
    LargeGreen = 3,
    SmallGreen = 5
}

--[[
    Draws a circle thing at a position. Takes a color from the HighlightCoords table.

    pos - vector3
    color - number
]]
function Render:HighlightCoords(pos, color)
    TypeCheck:Position3D(pos)

    HighlightPlacementCoords(pos.x, pos.y, pos.z, color or HighlightCoordsColors.Red)
end

--[[
    Resets Render:SetDrawOrigin()
]]
function Render:ResetDrawOrigin()
    ClearDrawOrigin()
end

--[[
    Draws whatever comes next in 3D space. Applies to all drawn elements afterwards.
    Must be reset using Render:ClearDrawOrigin()

    pos - table containing x,y,z coords
]]
function Render:SetDrawOrigin(pos)
    TypeCheck:Position3D(pos)
    SetDrawOrigin(pos.x, pos.y, pos.z, 0)
end

--[[
    Draws sprite on the screen

    pos - table containing x and y coords of sprite position
    size - table containing x and y sizes (relative to screen x and y size, ranges from 0-1)
    rotation - number of sprite rotation in degrees
    color - table of rgba values (or Color class)
    textureDict - Name of texture dictionary to load texture from (e.g. "CommonMenu", "MPWeaponsCommon", etc.)
    textureName - Name of texture to load from texture dictionary (e.g. "last_team_standing_icon", "tennis_icon", etc.)


    textureDict and textureName can be found through OpenIV,
    or you can find a small list here: https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs
]]
function Render:DrawSprite(pos, size, rotation, color, textureDict, textureName)
    TypeCheck:Position(pos)
    TypeCheck:Size(size)
    TypeCheck:Number(rotation)
    TypeCheck:Color(color)
    TypeCheck:Text(textureDict)
    TypeCheck:Text(textureName)

    if not HasStreamedTextureDictLoaded(textureDict) then
        RequestStreamedTextureDict(textureDict, false);
    else
        DrawSprite(textureDict, textureName, pos.x, pos.y, tofloat(size.x), tofloat(size.y), tofloat(rotation), color.r, color.g, color.b, color.a)
    end
end

--[[
    Draws a line from pos to pos2 in the ingame world

    pos - table of x,y,z
    pos2 - table of x,y,z
    color - table of rgba values (or Color class)
]]
function Render:DrawLine(pos, pos2, color)
    TypeCheck:Position3D(pos)
    TypeCheck:Position3D(pos2)
    TypeCheck:Color(color)
    DrawLine(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z, color.r, color.g, color.b, color.a)
end

--[[
    Draws a box in the ingame world. Cannot be rotated

    pos - table of x,y,z
    pos2 - table of x,y,z
    color - table of rgba values (or Color class)
]]
function Render:DrawBox(pos, pos2, color)
    TypeCheck:Position3D(pos)
    TypeCheck:Position3D(pos2)
    TypeCheck:Color(color)
    DrawBox(pos.x, pos.y, pos.z, pos2.x, pos2.y, pos2.z, color.r, color.g, color.b, color.a)
end

--[[
    Draws a rectangle on the screen.

    pos - table containing x and y coords of text position
    size - table containing x and y sizes
    color - table of rgba values (or Color class)
]]
function Render:FillArea(pos, size, color)
    TypeCheck:Position(pos)
    TypeCheck:Color(color)
    DrawRect(pos.x, pos.y, size.x, size.y, color.r, color.g, color.b, color.a, true, true)
end

--[[
    Gives the next text drawn to the screen an edge/outline

    width - number of the width of the edge
    color - table of rgba values (or Color class)
]]
function Render:SetTextEdge(width, color)
    TypeCheck:Number(width)
    TypeCheck:Color(color)
    SetTextEdge(width, color.r, color.g, color.b, color.a)
    SetTextOutline()
end

--[[
    Draws text with a shadow to the screen.

    s_distance - number of shadow distance
    s_color - color of the shadow
]]
function Render:SetTextDropShadow(s_distance, s_color)
    TypeCheck:Number(s_distance)
    TypeCheck:Color(s_color)
    SetTextDropshadow(s_distance, s_color.r, s_color.g, s_color.b, s_color.a)
    SetTextDropShadow()
end

if IsRedM then
    --[[
        Draws text to the screen.

        pos - table containing x and y coords of text position (0-1, 0-1)
        text - string of text you want to display
        color - table of rgba values (or Color class)
        scale - number of text scale
        enableShadow - if shadow is enabled
    ]]
    function Render:DrawText(pos, text, color, scale, enableShadow)
        TypeCheck:Number(scale)
        TypeCheck:Color(color)
        TypeCheck:Text(text)
        TypeCheck:Position(pos)

        local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 10, "LITERAL_STRING", tostring(text), Citizen.ResultAsLong())
        SetTextScale(tofloat(scale), tofloat(scale))
        SetTextColor(math.floor(color.r), math.floor(color.g), math.floor(color.b), math.floor(color.a))
        if enableShadow then SetTextDropshadow(1, 0, 0, 0, 255) end
        DisplayText(str, pos.x, pos.y)
    end
elseif IsFiveM then
    --[[
        Draws text to the screen.
        pos - table containing x and y coords of text position (0-1, 0-1)
        text - string of text you want to display
        color - table of rgba values (or Color class)
        scale - number of text scale
        font (optional) - number 0-4 that specifies the font of the text
    ]]
    function Render:DrawText(pos, text, color, scale, font)
        font = font or 0
        text = tostring(text)
        TypeCheck:Number(scale)
        TypeCheck:Color(color)
        TypeCheck:Position(pos)
        SetTextFont(font)
        SetTextScale(1, scale + 0.00000001) -- For some reason it can't be 1 LOL
        SetTextColour(color.r, color.g, color.b, color.a)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(pos.x, pos.y)
    end
end

Render = Render()