
-- Color class
Color = class()

function Color:__init(r, g, b, a)
    -- Hex
    if type(r) == "string" then
        r, g, b = self:HexToRGB(r)
    end

    self.r = r ~= nil and math.floor(r) or 255
    self.g = g ~= nil and math.floor(g) or 255
    self.b = b ~= nil and math.floor(b) or 255
    self.a = a ~= nil and math.floor(a) or 255
    self.a_percentage_float = self.a / 255.0
end

function Color:HexToRGB(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

function Color:tostring()
    return string.format("rgba(%d, %d, %d, %d)", self.r, self.g, self.b, self.a / 255)
end

--[[
 * Converts an HSV color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes h, s, and v are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  v       The value
 * @return  Array           The RGB representation
]]
function Color:FromHSV(h, s, v, a)
    a = a or 1
    local r, g, b
  
    local i = math.floor(h * 6);
    local f = h * 6 - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);
  
    i = i % 6
  
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
  
    return Color(math.ceil(r * 255), math.ceil(g * 255), math.ceil(b * 255), math.ceil(a * 255))
end
  

Colors = {}
Colors.RDR2 = -- Colors used in RDR2 stuff like notifications
{
    ["Red"] = "~e~",
    ["Yellow"] = "~o~",
    ["Orange"] = "~d~",
    ["Grey"] = "~m~",
    ["White"] = "~q~",
    ["Light Grey"] = "~t~",
    ["Black"] = "~v~",
    ["Pink"] = "~u~",
    ["Purple"] = "~t1~",
    ["Orange"] = "~t2~",
    ["Light Blue"] = "~t3~",
    ["Yellow"] = "~t4~",
    ["Light Pink"] = "~t5~",
    ["Green"] = "~t6~",
    ["Dark Blue"] = "~t7~",
    ["Light Red"] = "~t8~",
}

Colors.GTAV = -- Colors used in GTAV stuff like notifications
{
    ["Red"] = "~r~",
    ["Blue"] = "~b~",
    ["Green"] = "~g~",
    ["Yellow"] = "~y~",
    ["Purple"] = "~p~",
    ["Orange"] = "~o~",
    ["Gray"] = "~c~",
    ["Darkgray"] = "~m~",
    ["Black"] = "~u~",
    ["Newline"] = "~n~",
    ["Defaultwhite"] = "~s~",
    ["White"] = "~w~",
    ["Bold"] = "~h~"
}

Colors.Console = -- Colors used in console and server name
{
    ["Red"] = "^1",
    ["Green"] = "^2",
    ["Yellow"] = "^3",
    ["Blue"] = "^4",
    ["LightBlue"] = "^5",
    ["Purple"] = "^6",
    ["Default"] = "^7",
    ["DarkRed"] = "^8",
    ["Fuchsia"] = "^9",
    ["White"] = "^0"
}

Colors.AliceBlue = Color('#F0F8FF')
Colors.AntiqueWhite = Color('#FAEBD7')
Colors.Aqua = Color('#00FFFF')
Colors.Aquamarine = Color('#7FFFD4')
Colors.Azure = Color('#F0FFFF')
Colors.Beige = Color('#F5F5DC')
Colors.Bisque = Color('#FFE4C4')
Colors.Black = Color('#000000')
Colors.BlanchedAlmond = Color('#FFEBCD')
Colors.Blue = Color('#0000FF')
Colors.BlueViolet = Color('#8A2BE2')
Colors.Brown = Color('#A52A2A')
Colors.BurlyWood = Color('#DEB887')
Colors.CadetBlue = Color('#5F9EA0')
Colors.Chartreuse = Color('#7FFF00')
Colors.Chocolate = Color('#D2691E')
Colors.Coral = Color('#FF7F50')
Colors.CornflowerBlue = Color('#6495ED')
Colors.Cornsilk = Color('#FFF8DC')
Colors.Crimson = Color('#DC143C')
Colors.Cyan = Color('#00FFFF')
Colors.DarkBlue = Color('#00008B')
Colors.DarkCyan = Color('#008B8B')
Colors.DarkGoldenrod = Color('#B8860B')
Colors.DarkGray = Color('#A9A9A9')
Colors.DarkGreen = Color('#006400')
Colors.DarkKhaki = Color('#BDB76B')
Colors.DarkMagenta = Color('#8B008B')
Colors.DarkOliveGreen = Color('#556B2F')
Colors.DarkOrange = Color('#FF8C00')
Colors.DarkOrchid = Color('#9932CC')
Colors.DarkRed = Color('#8B0000')
Colors.DarkSalmon = Color('#E9967A')
Colors.DarkSeaGreen = Color('#8FBC8F')
Colors.DarkSlateBlue = Color('#483D8B')
Colors.DarkSlateGray = Color('#2F4F4F')
Colors.DarkTurquoise = Color('#00CED1')
Colors.DarkViolet = Color('#9400D3')
Colors.DeepPink = Color('#FF1493')
Colors.DeepSkyBlue = Color('#00BFFF')
Colors.DimGray = Color('#696969')
Colors.DodgerBlue = Color('#1E90FF')
Colors.Firebrick = Color('#B22222')
Colors.FloralWhite = Color('#FFFAF0')
Colors.ForestGreen = Color('#228B22')
Colors.Fuchsia = Color('#FF00FF')
Colors.Gainsboro = Color('#DCDCDC')
Colors.GhostWhite = Color('#F8F8FF')
Colors.Gold = Color('#FFD700')
Colors.Goldenrod = Color('#DAA520')
Colors.Gray = Color('#808080')
Colors.Green = Color('#008000')
Colors.GreenYellow = Color('#ADFF2F')
Colors.Honeydew = Color('#F0FFF0')
Colors.HotPink = Color('#FF69B4')
Colors.IndianRed = Color('#CD5C5C')
Colors.Indigo = Color('#4B0082')
Colors.Ivory = Color('#FFFFF0')
Colors.Khaki = Color('#F0E68C')
Colors.Lavender = Color('#E6E6FA')
Colors.LavenderBlush = Color('#FFF0F5')
Colors.LawnGreen = Color('#7CFC00')
Colors.LemonChiffon = Color('#FFFACD')
Colors.LightBlue = Color('#ADD8E6')
Colors.LightCoral = Color('#F08080')
Colors.LightCyan = Color('#E0FFFF')
Colors.LightGoldenrodYellow = Color('#FAFAD2')
Colors.LightGray = Color('#D3D3D3')
Colors.LightGreen = Color('#90EE90')
Colors.LightPink = Color('#FFB6C1')
Colors.LightSalmon = Color('#FFA07A')
Colors.LightSeaGreen = Color('#20B2AA')
Colors.LightSkyBlue = Color('#87CEFA')
Colors.LightSlateGray = Color('#778899')
Colors.LightSteelBlue = Color('#B0C4DE')
Colors.LightYellow = Color('#FFFFE0')
Colors.Lime = Color('#00FF00')
Colors.LimeGreen = Color('#32CD32')
Colors.Linen = Color('#FAF0E6')
Colors.Magenta = Color('#FF00FF')
Colors.Maroon = Color('#800000')
Colors.MediumAquamarine = Color('#66CDAA')
Colors.MediumBlue = Color('#0000CD')
Colors.MediumOrchid = Color('#BA55D3')
Colors.MediumPurple = Color('#9370DB')
Colors.MediumSeaGreen = Color('#3CB371')
Colors.MediumSlateBlue = Color('#7B68EE')
Colors.MediumSpringGreen = Color('#00FA9A')
Colors.MediumTurquoise = Color('#48D1CC')
Colors.MediumVioletRed = Color('#C71585')
Colors.MidnightBlue = Color('#191970')
Colors.MintCream = Color('#F5FFFA')
Colors.MistyRose = Color('#FFE4E1')
Colors.Moccasin = Color('#FFE4B5')
Colors.NavajoWhite = Color('#FFDEAD')
Colors.Navy = Color('#000080')
Colors.OldLace = Color('#FDF5E6')
Colors.Olive = Color('#808000')
Colors.OliveDrab = Color('#6B8E23')
Colors.Orange = Color('#FFA500')
Colors.OrangeRed = Color('#FF4500')
Colors.Orchid = Color('#DA70D6')
Colors.PaleGoldenrod = Color('#EEE8AA')
Colors.PaleGreen = Color('#98FB98')
Colors.PaleTurquoise = Color('#AFEEEE')
Colors.PaleVioletRed = Color('#DB7093')
Colors.PapayaWhip = Color('#FFEFD5')
Colors.PeachPuff = Color('#FFDAB9')
Colors.Peru = Color('#CD853F')
Colors.Pink = Color('#FFC0CB')
Colors.Plum = Color('#DDA0DD')
Colors.PowderBlue = Color('#B0E0E6')
Colors.Purple = Color('#800080')
Colors.Red = Color('#FF0000')
Colors.RosyBrown = Color('#BC8F8F')
Colors.RoyalBlue = Color('#4169E1')
Colors.SaddleBrown = Color('#8B4513')
Colors.Salmon = Color('#FA8072')
Colors.SandyBrown = Color('#F4A460')
Colors.SeaGreen = Color('#2E8B57')
Colors.SeaShell = Color('#FFF5EE')
Colors.Sienna = Color('#A0522D')
Colors.Silver = Color('#C0C0C0')
Colors.SkyBlue = Color('#87CEEB')
Colors.SlateBlue = Color('#6A5ACD')
Colors.SlateGray = Color('#708090')
Colors.Snow = Color('#FFFAFA')
Colors.SpringGreen = Color('#00FF7F')
Colors.SteelBlue = Color('#4682B4')
Colors.Tan = Color('#D2B48C')
Colors.Teal = Color('#008080')
Colors.Thistle = Color('#D8BFD8')
Colors.Tomato = Color('#FF6347')
Colors.Transparent = Color('#00FFFFFF')
Colors.Turquoise = Color('#40E0D0')
Colors.Violet = Color('#EE82EE')
Colors.Wheat = Color('#F5DEB3')
Colors.White = Color('#FFFFFF')
Colors.WhiteSmoke = Color('#F5F5F5')
Colors.Yellow = Color('#FFFF00')
Colors.YellowGreen = Color('#9ACD32')