if IsFiveM then
ScreenEffects = class()

--[[
    toggle blurred screen
]]
function ScreenEffects:Blur(enabled)
    assert(type(enabled) == "bool", "enabled expected to be a bool")
    if enabled then
        TransitionToBlurred(1)
    else
        TransitionFromBlurred(1)
    end
end

--[[
    Starts a screen effect.
    Name is from ScreenEffect list, time is in ms, and loop is bool
]]
function ScreenEffects:Start(name, time, loop)
    assert(type(name) == "string", "name expected to be a string")
    assert(type(time) == "number", "time expected to be a number")
    assert(type(loop) == "bool", "loop expected to be a bool")
    StartScreenEffect(name, time, loop)
end

--[[
    Stops a screen effect with specified name
]]
function ScreenEffects:Stop(name)
    assert(type(name) == "string", "name expected to be a string")
    StopScreenEffect(name)
end

--[[
    Stops all screen effects.
]]
function ScreenEffects:StopAll()
    StopAllScreenEffects()
end

ScreenEffects = ScreenEffects()

ScreenEffect = {
    "SwitchHUDIn",
    "SwitchHUDOut",
    "FocusIn",
    "FocusOut",
    "MinigameEndNeutral",
    "MinigameEndTrevor",
    "MinigameEndFranklin",
    "MinigameEndMichael",
    "MinigameTransitionOut",
    "MinigameTransitionIn",
    "SwitchShortNeutralIn",
    "SwitchShortFranklinIn",
    "SwitchShortTrevorIn",
    "SwitchShortMichaelIn",
    "SwitchOpenMichaelIn",
    "SwitchOpenFranklinIn",
    "SwitchOpenTrevorIn",
    "SwitchHUDMichaelOut",
    "SwitchHUDFranklinOut",
    "SwitchHUDTrevorOut",
    "SwitchShortFranklinMid",
    "SwitchShortMichaelMid",
    "SwitchShortTrevorMid",
    "DeathFailOut",
    "CamPushInNeutral",
    "CamPushInFranklin",
    "CamPushInMichael",
    "CamPushInTrevor",
    "SwitchOpenMichaelIn",
    "SwitchSceneFranklin",
    "SwitchSceneTrevor",
    "SwitchSceneMichael",
    "SwitchSceneNeutral",
    "MP_Celeb_Win",
    "MP_Celeb_Win_Out",
    "MP_Celeb_Lose",
    "MP_Celeb_Lose_Out",
    "DeathFailNeutralIn",
    "DeathFailMPDark",
    "DeathFailMPIn",
    "MP_Celeb_Preload_Fade",
    "PeyoteEndOut",
    "PeyoteEndIn",
    "PeyoteIn",
    "PeyoteOut",
    "MP_race_crash",
    "SuccessFranklin",
    "SuccessTrevor",
    "SuccessMichael",
    "DrugsMichaelAliensFightIn",
    "DrugsMichaelAliensFight",
    "DrugsMichaelAliensFightOut",
    "DrugsTrevorClownsFightIn",
    "DrugsTrevorClownsFight",
    "DrugsTrevorClownsFightOut",
    "HeistCelebPass",
    "HeistCelebPassBW",
    "HeistCelebEnd",
    "HeistCelebToast",
    "MenuMGHeistIn",
    "MenuMGTournamentIn",
    "MenuMGSelectionIn",
    "ChopVision",
    "DMT_flight_intro",
    "DMT_flight",
    "DrugsDrivingIn",
    "DrugsDrivingOut",
    "SwitchOpenNeutralFIB5",
    "HeistLocate",
    "MP_job_load",
    "RaceTurbo",
    "MP_intro_logo",
    "HeistTripSkipFade",
    "MenuMGHeistOut",
    "MP_corona_switch",
    "MenuMGSelectionTint",
    "SuccessNeutral",
    "ExplosionJosh3",
    "SniperOverlay",
    "RampageOut",
    "Rampage",
    "Dont_tazeme_bro",
    "DeathFailOut"
}
end