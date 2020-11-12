if not IsFiveM then return end

Texture = class()

TextureTypes = {Dui = 1, Image = 2}
local texture_id = 0
local TEXTURE_DICT = CreateRuntimeTxd("Texture_OOF_Dict")

local function GetTextureName()
    texture_id = texture_id + 1
    return "Texture_" .. tostring(texture_id)
end

--[[
    Creates a new texture that can be used with Render:DrawTexture

    args (in table):
        width (int): width of the texture
        height (int): height of the texture
        type (TextureTypes): type of the source of the texture
        source (string): path to the texture. Can be png, jpg, html, etc
        position (vector2): position of texture on screen
        rotation (number) (optional): rotation of the texture
]]
function Texture:__init(args)

    self.height = args.height
    self.width = args.width
    self.size = vector2(self.width, self.height)
    self.type = args.type
    self.source = args.source
    self.position = args.position or vector2(0, 0)
    
    Citizen.CreateThread(function()
        self:Create()
    end)
end

function Texture:Create()
    print("Creating texture...")
    Citizen.Wait(1000)
    self.txn = GetTextureName()
    Citizen.Wait(1000)
    print("Texture name: " .. self.txn)
    Citizen.Wait(1000)

    if self.type == TextureTypes.Dui then
        print("Creating dui object with source " .. tostring(self.source) .. " width " .. tostring(self.width) .. " height " .. tostring(self.height))
        Citizen.Wait(1000)
        self.dui_obj = Citizen.InvokeNative(0x23EAF899, self.source, self.width, self.height, Citizen.ResultAsLong())
        Citizen.Wait(1000)
        print("Getting dui handle")
        Citizen.Wait(1000)
        self.dui = GetDuiHandle(self.dui_obj)
        Citizen.Wait(1000)
        print("CreateRuntimeTextureFromDuiHandle")
        Citizen.Wait(1000)
        self.tx = CreateRuntimeTextureFromDuiHandle(TEXTURE_DICT, self.txn, self.dui)
        Citizen.Wait(1000)
        
    elseif self.type == TextureTypes.Image then
        self.tx = CreateRuntimeTextureFromImage(TEXTURE_DICT, self.txn, self.source)
    end

    print("Done")
end

function Texture:SetPosition(pos)
    self.position = pos
end

function Texture:SetRotation(rot)
    self.rotation = rot
end

function Texture:Draw()
    Render:DrawSprite(self.position, self.size, self.rotation, Colors.White)
end

function Texture:Destroy()
    if self.type == TextureTypes.Dui then DestroyDui(self.dui_obj) end
end