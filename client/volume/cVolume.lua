if IsRedM then
    
Volume = class()

VolumeType = 
{
    Sphere = 1,
    Box = 2,
    Cylinder = 3
}

--[[
    Creates a new Volume, aka an area within the game. Use Entity:IsInVolume(Volume) to detect
    if an entity is within the volume.

    args (in table):
        position (vector3): position of the volume
        rotation (vector3): rotation of the volume
        size (vector3): size of the volume
        type (VolumeType): type of the volume
]]
function Volume:__init(args)

    local volume_func_hash

    if args.type == VolumeType.Sphere then
        volume_func_hash = 0xB3FB80A32BAE3065
    elseif args.type == VolumeType.Box then
        volume_func_hash = 0xDF85637F22706891
    elseif args.type == VolumeType.Cylinder then
        volume_func_hash = 0x0522D4774B82E3E6
    end

    self.volume = Citizen.InvokeNative(volume_func_hash, 
        args.position.x, args.position.y, args.position.z,
        args.rotation.x, args.rotation.y, args.rotation.z,
        args.size.x, args.size.y, args.size.z
    )

end

function Volume:GetHandle()
    return self.volume
end

function Volume:Remove()
    Citizen.InvokeNative(0x43F867EF5C463A53, self.volume)
end

end