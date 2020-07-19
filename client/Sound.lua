Sound = class()

--[[
    Creates a new sound instance so you can play sounds.

    args:

    position - (optional) vector3 where you want it to be played from
    entity - (optional) entity you want it to be played from
    audioName - the name of the audio file from the audioRef
    audioRef - the audio bank with the file you want to play
    autoplay - (optional) bool of whether you want the sound to play automatically (good for one-shots)
]]
function Sound:__init(args)
    assert(type(args.audioName) == "string", "args.audioName expected to be a string")
    assert(type(args.audioRef) == "string", "args.audioRef expected to be a string")
    assert(args.position == nil and args.entity == nil, "args.position or args.entity expected, none given")

    self.id = GetSoundId()
    self.position = args.position or vector3(0,0,0)

    self.entity = args.entity

    self.audioName = args.audioName
    self.audioRef = args.audioRef

    if args.autoplay then
        self:Play()
    end
end

function Sound:SetPosition(pos)
    assert(type(pos) == "vector3", "position expected to be a vector3")
    self.position = pos
end

function Sound:GetPosition()
    return self.position
end

function Sound:PlayFromCoord(pos)
    PlaySoundFromCoord(self.id, self.audioName, pos.x, pos.y, pos.z + 0.5 , self.audioRef, 1, 100, 0)
end

function Sound:PlayFromEntity(entity)
    PlaySoundFromEntity(self.id, self.audioName, entity, self.audioRef, 1, 1)
end

function Sound:PlayFrontend()
    PlaySoundFrontend(self.id, self.audioName, self.audioRef, 1)
end

--[[
    Plays the sound.
]]
function Sound:Play()
    if self.entity then
        self:PlayFromEntity(self.entity)
    elseif self.position then
        self:PlayFromCoord(self.position)
    else
        self:PlayFrontend()
    end
end

function Sound:SetVariable(var, val)
    SetVariableOnSound(self.id, var, val)
end

function Sound:IsFinishedPlaying()
    return HasSoundFinished(self.id)
end

function Sound:Stop()
    StopSound(self.id)
end

function Sound:Remove()
    self:Stop()
    ReleaseSoundId(self.id)
end