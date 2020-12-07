AnimPostFX = class()

function AnimPostFX:__init()

end

function AnimPostFX:Play(name)
    AnimpostfxPlay(name)
end

function AnimPostFX:Stop(name)
    AnimpostfxStop(name)
end

if IsRedM then
	AnimPostFX = AnimPostFX()
end

-- List of FX names from https://github.com/femga/rdr3_discoveries/blob/master/graphics/animpostfx/animpostfx.lua
--[[local animpostfx = {

	"CameraTakePicture",
	"CameraTransitionBlink",
	"CameraTransitionFlash",
	"CameraTransitionWipe_L",
	"CameraTransitionWipe_R",
	"CameraViewfinder",
	"CamTransition01",
	"CamTransitionBlink",
	"CamTransitionBlinkSick",
	"CamTransitionBlinkSlow",
	"ChapterTitle_IntroCh01",
	"ChapterTitle_IntroCh02",
	"ChapterTitle_IntroCh03",
	"ChapterTitle_IntroCh04",
	"ChapterTitle_IntroCh05",
	"ChapterTitle_IntroCh06",
	"ChapterTitle_IntroCh08Epi01",
	"ChapterTitle_IntroCh09Epi02",
	"cutscene_mar6_train",
	"cutscene_rbch2rsc11_bink1",
	"cutscene_rbch2rsc11_bink2",
	"cutscene_rbch2rsc11_bink3",
	"cutscene_rbch2rsc11_bink4",
	"cutscene_rbch2rsc11_bink5",
	"cutscene_rbch2rsc11_bink6",
	"cutscene_rbch2rsc11_bink7",
	"cutscene_rbch2rsc11_bink8",
	"deadeye",
	"DeadEyeEmpty",
	"DeathFailMP01",
	"Duel",
	"EagleEye",
	"GunslingerFill",
	"killCam",
	"KillCamHonorChange",
	"KingCastleBlue",
	"KingCastleRed",
	"MissionChoice",
	"MissionFail01",
	"Mission_EndCredits",
	"Mission_FIN1_RideBad",
	"Mission_FIN1_RideGood",
	"Mission_GNG0_Ride",
	"MP_BountyLagrasSwamp",
	"MP_BountySelection",
	"MP_CampWipeDown",
	"MP_CampWipeL",
	"MP_CampWipeR",
	"MP_CampWipeUp",
	"MP_DM_Annesburg_ReduceDustDensity",
	"MP_Downed",
	"MP_HealthDrop",
	"MP_InRegion_Exit",
	"MP_LobbyBW01_Intro",
	"MP_OutofAreaDirectional",
	"MP_PedKill",
	"MP_RaceBoostStart",
	"MP_Region",
	"MP_RewardsExposureLoop",
	"MP_Rhodes_ReduceDustDensity",
	"MP_RiderFormation",
	"MP_SuddenDeath",
	"ODR3_Injured01Loop",
	"ODR3_Injured02Loop",
	"ODR3_Injured03Loop",
	"OJDominoBlur",
	"OJDominoValid",
	"OJFiveFinger",
	"OJPokerPlayerTurn",
	"PauseMenuIn",
	"PedKill",
	"PlayerDrugsPoisonWell",
	"PlayerDrunk01",
	"PlayerDrunk01_PassOut",
	"PlayerDrunkAberdeen",
	"PlayerDrunkSaloon1",
	"PlayerHealthCrackpot",
	"PlayerHealthLow",
	"PlayerHealthPoorCS",
	"PlayerHealthPoorGuarma",
	"PlayerHealthPoorMOB3",
	"PlayerHonorChoiceBad",
	"PlayerHonorChoiceGood",
	"PlayerHonorLevelBad",
	"PlayerHonorLevelGood",
	"PlayerImpact04",
	"PlayerImpactFall",
	"PlayerKnockout_SerialKiller",
	"PlayerKnockout_WeirdoPat",
	"PlayerOverpower",
	"PlayerRPGCore",
	"PlayerRPGCoreDeadEye",
	"PlayerRPGEmptyCoreDeadEye",
	"PlayerRPGEmptyCoreHealth",
	"PlayerRPGEmptyCoreStamina",
	"PlayerRPGWarnHealth",
	"PlayerSickDoctorsOpinion",
	"PlayerSickDoctorsOpinionOutBad",
	"PlayerSickDoctorsOpinionOutGood",
	"PlayerWakeUpAberdeen",
	"PlayerWakeUpDrunk",
	"PlayerWakeUpInterrogation",
	"PlayerWakeUpKnockout",
	"PoisonDartPassOut",
	"POSTFX_CONSUMABLE_STAMINA",
	"POSTFX_CONSUMABLE_STAMINA_FORT",
	"RespawnEstablish01",
	"RespawnMissionCheckpoint",
	"RespawnPulse01",
	"RespawnSkyWithHonor",
	"RespawnWithHonor",
	"SkyTimelapse_0600_01",
	"skytl_0000_01clear",
	"skytl_0600_01clear",
	"skytl_0900_01clear",
	"skytl_0900_04storm",
	"skytl_1200_01clear",
	"skytl_1200_03clouds",
	"skytl_1500_03clouds",
	"skytl_1500_04storm",
	"title_ch01_colter",
	"Title_Ch03_ClemensPoint",
	"Title_GameIntro",
	"Title_Gen_coupledayslater",
	"Title_Gen_coupledayslater_onblack",
	"Title_Gen_couplemonthslater",
	"Title_Gen_couplemonthslater_onblack",
	"Title_Gen_coupleweekslater",
	"Title_Gen_coupleweekslater_onblack",
	"Title_Gen_daylater",
	"Title_Gen_daylater_onblack",
	"Title_Gen_FewDaysLater",
	"Title_Gen_FewDaysLater_onblack",
	"Title_Gen_FewHoursLater",
	"Title_Gen_FewHoursLater_onblack",
	"Title_Gen_FewMonthsLater",
	"Title_Gen_FewMonthsLater_onblack",
	"Title_Gen_FewWeeksLater",
	"Title_Gen_FewWeeksLater_onblack",
	"Title_Gen_somedaysLater",
	"Title_Gen_somedaysLater_onblack",
	"Title_Gen_someyearsLater",
	"Title_Gen_someyearsLater_onblack",
	"UI_PauseTransition",
	"UI_PauseTransitionOut",
	"WheelHUDIn",
}]]

--[[
List of FiveM FX names: https://pastebin.com/dafBAjs0

LIST OF SCREEN FX
 
INFO : Somes effect are directly loop and need to be stop
 
START_SCREEN_EFFECT(FxName, 0, false);
STOP_SCREEN_EFFECT(FxName);
 
SwitchHUDIn
SwitchHUDOut
FocusIn
FocusOut
MinigameEndNeutral
MinigameEndTrevor
MinigameEndFranklin
MinigameEndMichael
MinigameTransitionOut
MinigameTransitionIn
SwitchShortNeutralIn
SwitchShortFranklinIn
SwitchShortTrevorIn
SwitchShortMichaelIn
SwitchOpenMichaelIn
SwitchOpenFranklinIn
SwitchOpenTrevorIn
SwitchHUDMichaelOut
SwitchHUDFranklinOut
SwitchHUDTrevorOut
SwitchShortFranklinMid
SwitchShortMichaelMid
SwitchShortTrevorMid
DeathFailOut
CamPushInNeutral
CamPushInFranklin
CamPushInMichael
CamPushInTrevor
SwitchOpenMichaelIn
SwitchSceneFranklin
SwitchSceneTrevor
SwitchSceneMichael
SwitchSceneNeutral
MP_Celeb_Win
MP_Celeb_Win_Out
MP_Celeb_Lose
MP_Celeb_Lose_Out
DeathFailNeutralIn
DeathFailMPDark
DeathFailMPIn
MP_Celeb_Preload_Fade
PeyoteEndOut
PeyoteEndIn
PeyoteIn
PeyoteOut
MP_race_crash
SuccessFranklin
SuccessTrevor
SuccessMichael
DrugsMichaelAliensFightIn
DrugsMichaelAliensFight
DrugsMichaelAliensFightOut
DrugsTrevorClownsFightIn
DrugsTrevorClownsFight
DrugsTrevorClownsFightOut
HeistCelebPass
HeistCelebPassBW
HeistCelebEnd
HeistCelebToast
MenuMGHeistIn
MenuMGTournamentIn
MenuMGSelectionIn
ChopVision
DMT_flight_intro
DMT_flight
DrugsDrivingIn
DrugsDrivingOut
SwitchOpenNeutralFIB5
HeistLocate
MP_job_load
RaceTurbo
MP_intro_logo
HeistTripSkipFade
MenuMGHeistOut
MP_corona_switch
MenuMGSelectionTint
SuccessNeutral
ExplosionJosh3
SniperOverlay
RampageOut
Rampage
Dont_tazeme_bro
DeathFailOut


]]