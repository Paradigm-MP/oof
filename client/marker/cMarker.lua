Marker = class()

if IsRedM then
    -- Partially from here https://github.com/femga/rdr3_discoveries/blob/master/graphics/markers/marker_types.lua
    MarkerTypes = 
    {
        Box = 1857541051, 
        Cylinder = -1795314153,
        Sphere = 0x50638AB9,
        Ring = 0xEC032ADD,
        Halo = 0x6903B113,
        RaceCheckpoint = 0xE60FF3B9,
        RaceFinish = 0x664669A6,
        CanoePole = 0xE03A92AE,
        Buoy = 0x751F27D6
    }
elseif IsFiveM then
    -- Add more markers from this list as needed: https://docs.fivem.net/docs/game-references/markers/
    MarkerTypes = 
    {
        UpsideDownCone = 0,
        VerticalCylinder = 1,
        DebugSphere = 28
    }
end

--[[
    Creates a new marker in the world, aka a glowly circle thing.

    args (in table):
        type (MarkerTypes): shape/type of the marker
        position (vector3): position of the marker in the world
        direction (vector3): direction of the marker 
        rotation (vector3): rotation of the marker
        scale (vector3): scale of the marker
        color (Color): color of the marker

        -- optional:
        bob_up_and_down (bool, default false): if the marker bobs up and down
        face_camera (bool, default false): if the marker faces the camera
        is_rotating (bool, default false): if the marker rotates
        texture_dict (string, default nil): if the marker uses a texture
        texture_name (string, default nil): if the marker uses a texture
        draw_on_entity (bool, default false): if the marker draws on entities
        rotation_order (number 0-2, default 1): rotation order of the marker

]]
function Marker:__init(args)

    self.type = args.type
    self.position = args.position
    self.direction = args.direction
    self.rotation = args.rotation
    self.scale = args.scale
    self.color = Color(args.color.r, args.color.g, args.color.b, args.color.a)

    self.bob_up_and_down = args.bob_up_and_down ~= nil and args.bob_up_and_down or false
    self.face_camera = args.face_camera ~= nil and args.face_camera or false
    self.is_rotating = args.is_rotating ~= nil and args.is_rotating or false
    self.texture_dict = args.texture_dict
    self.texture_name = args.texture_name
    self.draw_on_entity = args.draw_on_entity ~= nil and args.draw_on_entity or false

    self.rotation_order = args.rotation_order or 1

    self.visible = true

    self.render = Events:Subscribe("Render", self, self.Draw)
end

function Marker:SetVisible(visible)
    self.visible = visible
end

function Marker:SetColor(color)
    self.color = color
end

function Marker:FadeOut()
    self.fadeout = true
end

function Marker:Draw()
    if not self.visible then return end
    Citizen.InvokeNative(IsFiveM and 0x28477EC23D892089 or 0x2A32FAA57B937173,
        1,
        self.position.x, self.position.y, self.position.z,
        self.direction.x, self.direction.z, self.direction.z,
        self.rotation.x, self.rotation.y, self.rotation.z,
        self.scale.x, self.scale.y, self.scale.z,
        self.color.r, self.color.g, self.color.b, self.color.a,
        self.bob_up_and_down, self.face_camera,
        self.rotation_order, self.is_rotating, 
        self.texture_dict, self.texture_name,
        self.draw_on_entity
    )

    if self.fadeout then
        self.color.a = self.color.a - 1
        if self.color.a <= 0 then
            self:Remove()
        end
    end
end

function Marker:Remove()
    if self.render then self.render:Unsubscribe() end
    self.render = nil
end