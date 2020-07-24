Camera = class()

function Camera:__init()
    self.cam = GetRenderingCam()
    self:FadeIn(0)
end

-- Interpolates between two positions over duration ms
function Camera:InterpolateBetween(pos1, pos2, rot1, rot2, duration)
    assert(self.freecam == nil 
    and self.from_cam == nil
    and self.to_cam == nil, "cannot call Camera:InterpolateBetween multiple times without calling Camera:Reset first")
    
    ClearFocus()
    self.from_cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos1.x, pos1.y, pos1.z, rot1.x, rot1.y, rot1.z, self:GetFOV())
    self.to_cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos2.x, pos2.y, pos2.z, rot2.x, rot2.y, rot2.z, self:GetFOV())

    SetCamActiveWithInterp(self.to_cam, self.from_cam, duration)
    RenderScriptCams(true, false, 0, true, false, true)
    SetCamAffectsAiming(self.from_cam, false)
    SetCamAffectsAiming(self.to_cam, false)
end

function Camera:DetachFromPlayer()
    assert(self.freecam == nil 
    and self.from_cam == nil
    and self.to_cam == nil, "cannot call Camera:DetachFromPlayer multiple times without calling Camera:Reset first")
    
    ClearFocus()
    self.freecam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", LocalPlayer:GetPosition(), 0, 0, 0, self:GetFOV())
    SetCamActive(self:GetCurrentCam(), true)
    RenderScriptCams(true, false, 0, true, false, true)
    SetCamAffectsAiming(self:GetCurrentCam(), false)
end

--[[
    Attaches the camera to a player. Must use DetachFromPlayer first.
    
    player is an instance of cPlayer
]]
function Camera:AttachToPlayer(player)
    assert(player:Exists(), "cannot Camera:AttachToPlayer that does not exist")
    assert(self:GetCurrentCam() == self.cam, "must use Camera:DetachFromPlayer before using Camera:AttachToPlayer")

    offsetCoords = GetOffsetFromEntityGivenWorldCoords(player:GetEntity(), self:GetPosition())
    AttachCamToEntity(self:GetCurrentCam(), entity, offsetCoords.x, offsetCoords.y, offsetCoords.z, true)
end

function Camera:Reset()
    ClearFocus()
    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(self.freecam, false)
    DestroyCam(self.from_cam, false)
    DestroyCam(self.to_cam, false)
    self.from_cam = nil
    self.to_cam = nil
    self.freecam = nil
end

function Camera:GetFOV()
    return GetGameplayCamFov()
end

function Camera:PointAtCoord(pos)
    PointCamAtCoord(self:GetCurrentCam(), pos.x, pos.y, pos.z)
end

function Camera:SetPosition(pos)
    SetCamCoord(self:GetCurrentCam(), pos.x, pos.y, pos.z)
end

function Camera:SetRotation(rot)
    SetCamRot(self:GetCurrentCam(), rot.x, rot.y, rot.z, 2)
end

CameraShakeType = 
{
    DEATH_FAIL_IN_EFFECT_SHAKE = "DEATH_FAIL_IN_EFFECT_SHAKE",
    DRUNK_SHAKE = "DRUNK_SHAKE",
    FAMILY5_DRUG_TRIP_SHAKE = "FAMILY5_DRUG_TRIP_SHAKE",
    HAND_SHAKE = "HAND_SHAKE",
    JOLT_SHAKE = "JOLT_SHAKE",
    LARGE_EXPLOSION_SHAKE = "LARGE_EXPLOSION_SHAKE",
    MEDIUM_EXPLOSION_SHAKE = "MEDIUM_EXPLOSION_SHAKE",
    SMALL_EXPLOSION_SHAKE = "SMALL_EXPLOSION_SHAKE",
    ROAD_VIBRATION_SHAKE = "ROAD_VIBRATION_SHAKE",
    SKY_DIVING_SHAKE = "SKY_DIVING_SHAKE",
    VIBRATE_SHAKE = "VIBRATE_SHAKE"
}
--[[
    Shakes the Camera with intensity.

    shakeType is a CameraShakeType enum. Intensity is a number
]]
function Camera:Shake(shakeType, intensity)
    ShakeGameplayCam(shakeType, tofloat(intensity))
end

--[[
    Fades in the camera from black over time in ms
]]
function Camera:FadeIn(time)
    DoScreenFadeIn(time)
end

--[[
    Fades out the camera from black over time in ms
]]
function Camera:FadeOut(time)
    DoScreenFadeOut(time)
end

--[[
    Returns whether the screen is black or not.
]]
function Camera:IsFadedOut()
    return IsScreenFadedOut()
end

--[[
    Returns true if the screen isn't faded out to black.
]]
function Camera:IsFadedIn()
    return IsScreenFadedIn()
end

function Camera:GetPosition()
    --return GetCamCoord(self:GetCurrentCam())
    return GetGameplayCamCoord()
end

function Camera:GetRotation()
    --return Vector3Math:RotationToDirection(GetCamRot(self:GetCurrentCam()))
    return Vector3Math:RotationToDirection(GetGameplayCamRot(0))
end

function Camera:GetCurrentCam()
    if self.freecam then return self.freecam end
    return self.cam
end

--[[
    rightVector --[[ vector3, forwardVector --[[ vector3, upVector --[[ vector3, position --[[ vector3
    Returns the world matrix of the specified camera. To turn this into a view matrix, calculate the inverse.
]]
function Camera:GetMatrix()
    return GetCamMatrix(self:GetCurrentCam())
end

Camera = Camera()