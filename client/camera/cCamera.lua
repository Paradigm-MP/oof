Camera = class()

function Camera:__init()
    self.cam = GetRenderingCam()
    self:FadeIn(0)
end

CameraViewMode = 
{
    ThirdPersonClose = 0,
    ThirdPersonMiddle = 1,
    ThirdPersonFar = 2,
    FirstPerson = 4
}

if IsFiveM then
    -- Locks the camera view mode to a specific CameraViewMode
    -- Must be called every frame to override manual controls
    -- unless you also disable the camera control with:
    -- LocalPlayer:RestrictAction(Control.NextCamera, true)
    function Camera:LockCameraMode(mode)
        if GetFollowPedCamViewMode() ~= mode or 
        GetFollowVehicleCamViewMode() ~= mode then
            SetFollowPedCamViewMode(mode)
            SetFollowVehicleCamViewMode(mode)
        end
    end
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

function Camera:SetFOV(fov)
    SetCamFov(self:GetCurrentCam(), tofloat(fov))
end

function Camera:DetachFromPlayer(position, rotation, ease, ease_time)
    assert(self.freecam == nil 
    and self.from_cam == nil
    and self.to_cam == nil, "cannot call Camera:DetachFromPlayer multiple times without calling Camera:Reset first")
    
    local pos = position or Camera:GetPosition()
    local rot = rotation or Camera:GetRotation()

    ClearFocus()
    self.freecam = CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA", 
        pos.x, pos.y, pos.z, 
        rot.y, rot.y, rot.z, 
        self:GetFOV())
    SetCamActive(self:GetCurrentCam(), true)
    RenderScriptCams(true, ease, ease_time, true, false, true)
    SetCamAffectsAiming(self:GetCurrentCam(), false)
end

--[[
    Attaches the camera to an entity. Must use DetachFromPlayer first.
]]
function Camera:AttachToEntity(entity, offset)
    assert(entity:Exists(), "cannot Camera:AttachToEntity on entity that does not exist")
    assert(self:GetCurrentCam() ~= self.cam, "must use Camera:DetachFromPlayer before using Camera:AttachToEntity")

    AttachCamToEntity(self:GetCurrentCam(), entity:GetEntityId(), offset.x, offset.y, offset.z, true)
end

function Camera:Reset(ease, ease_time)
    ClearFocus()
    RenderScriptCams(false, ease, ease_time or 0, true, false)
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

function Camera:PointAtEntity(entity)
    PointCamAtEntity(self:GetCurrentCam(), entity:GetEntityId(), 0.0, 0.0, 0.0, true)
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

function Camera:SetGameplayCamShakeAmplitude(amount)
    SetGameplayCamShakeAmplitude(tofloat(amount))
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