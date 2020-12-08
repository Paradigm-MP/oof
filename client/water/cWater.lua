if IsFiveM then

Water = class()

function Water:__init()

end

--[[
    This seems to edit the water wave, intensity around your current location.  
    0.0f = Normal  
    1.0f = So Calm and Smooth, a boat will stay still.  
    3.0f = Really Intense.

    You can also set the value as high as you want for some crazy looking water.
]]
function Water:SetWaveIntensity(intensity)
    WaterOverrideSetStrength(tofloat(intensity))
end

function Water:SetOceanWaveAmplitude(amplitude)
    WaterOverrideSetOceanwaveamplitude(amplitude)
end

--[[
    This function set height to the value of z-axis of the water surface.  
    This function works with sea and lake. However it does not work with shallow rivers (e.g. raton canyon will return -100000.0f)  
    note: seems to return true when you are in water  

    set ignore_waves to true if you want to ignore waves in this calculation
]]
function Water:GetHeightAtPos(pos, ignore_waves)
    if not ignore_waves then
        local water_exists, height = GetWaterHeight(pos.x, pos.y, pos.z)
        return height, water_exists
    else
        local water_exists, height = GetWaterHeightNoWaves(pos.x, pos.y, pos.z)
        return height, water_exists
    end
end

--[[
    Sets the water height at specified position.

    Seems to only make a small impact if done every frame.
]]
function Water:SetHeightAtPos(pos, radius, height)
    ModifyWater(pos.x, pos.y, tofloat(radius), tofloat(height))
end

-- Does not seem do to anything
function Water:AddCurrentRise(x_low, y_low, x_high, y_high, height)
    AddCurrentRise(x_low, y_low, x_high, y_high, height)
end

Water = Water()

end