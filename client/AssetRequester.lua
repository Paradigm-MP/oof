function LoadModel(hash, callback)
    Citizen.CreateThread(function()
        local wait_time = 0
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(100)
            wait_time = wait_time + 100
            assert(wait_time < 5000, string.format("model with hash %s could not be loaded in time. Did you use the right hash?", hash))
        end
        callback()
        -- Clear up memory
        Citizen.SetTimeout(1000, function()
            SetModelAsNoLongerNeeded(hash)
        end)
    end)
end

function LoadEffectBank(bank, callback)
    Citizen.CreateThread(function()
        local wait_time = 0
        RequestNamedPtfxAsset(bank)
        while not HasNamedPtfxAssetLoaded(bank) do
            Citizen.Wait(100)
            wait_time = wait_time + 100
            assert(wait_time < 5000, string.format("effect bank %s could not be loaded in time. Did you use the right name?", bank))
        end
        callback()
        -- Clear up memory
        Citizen.SetTimeout(1000, function()
            RemoveNamedPtfxAsset(bank)
        end)
    end)
end


function LoadAnimSet(anim, callback)
    Citizen.CreateThread(function()
        local wait_time = 0
        RequestAnimSet(anim)
        while not HasAnimSetLoaded(anim) do
            Citizen.Wait(100)
            wait_time = wait_time + 100
            assert(wait_time < 5000, string.format("anim set %s could not be loaded in time. Did you use the right name?", anim))
        end
        callback()
        -- Clear up memory
        Citizen.SetTimeout(1000, function()
            RemoveAnimSet(anim)
        end)
    end)
end

function LoadAnimDict(dict, callback)
    Citizen.CreateThread(function()
        local wait_time = 0
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(100)
            wait_time = wait_time + 100
            assert(wait_time < 5000, string.format("anim dict %s could not be loaded in time. Did you use the right name?", dict))
        end
        callback()
        -- Clear up memory
        Citizen.SetTimeout(1000, function()
            RemoveAnimDict(dict)
        end)
    end)
end