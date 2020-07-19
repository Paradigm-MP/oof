HUD = class()

function HUD:__init()
    self.render = Events:Subscribe("Render", function() self:Render() end)
end

--[[
    Draws a frontend alert, like that seen here: http://www.kronzky.info/fivemwiki/index.php?title=DrawFrontendAlert

    args (in table):
        title (string) - title of the message
        subtitle (string) - (optional) subtitle of the message
        subtitle2 (string) - (optional) second subtitle
        no_bg (bool) - (optional) default false, set to true to remove the background
        time (number) - how long the alert should display for in seconds
]]
function HUD:DrawFrontendAlert(args)
    assert(type(args.time) == 'number', 'args.time expected to be a number')
    Citizen.CreateThread(function()
        AddTextEntry("FACES_WARNH2", args.title or '')
        AddTextEntry("QM_NO_0", args.subtitle or '')
        AddTextEntry("QM_NO_3", args.subtitle2 or '')
        local timer = Timer()
        while timer:GetSeconds() < args.time do
            Citizen.Wait(0)
            DrawFrontendAlert("FACES_WARNH2", "QM_NO_0", 3, 3, "QM_NO_3", 2, -1, false, "FM_NXT_RAC", "QM_NO_1", no_bg ~= true, false)
        end
    end)
end

--[[
    If the radar/minimap should be enabled or not
]]
function HUD:SetDisplayRadar(enabled)
    DisplayRadar(enabled)
end

function HUD:ShowComponent(hash)
    Citizen.InvokeNative(0x8BC7C1F929D07BF3, hash)
end

function HUD:HideComponent(hash)
    Citizen.InvokeNative(0x4CC5F2FC1332577F, hash)
end

--[[
    Toggles the display of the ammo in the top right
]]
function HUD:SetDisplayAmmo(enabled)
    self.display_ammo = enabled
end

--[[
    Toggles the display of the cash hud in the top right
]]
function HUD:SetDisplayCash(enabled)
    self.display_cash = enabled
end

--[[
    Toggles the display of the bank hud in the top right
]]
function HUD:SetDisplayBank(enabled)
    self.display_bank = enabled
end

function HUD:Render()
    --DisplayAmmoThisFrame(self.display_ammo) -- native does not exist
    --if not self.display_bank then RemoveMultiplayerBankCash() end -- native does not exist
    --if not self.display_cash then RemoveMultiplayerHudCash() end -- native does not exist
end

HUD = HUD()

HudComponent = {
    everything = -1679307491,
    minimapHonorAndCards = 724769646,
    minimap = 474191950,
    forceHonor = 121713391,
    onlyActionWheel = 2011163970,
    actionWheelWeapons = -1249243147,
    skillCards = 1058184710,
    onlyMoney = 1920936087,
    actionWheelFishing = 100665617,
    onlyFishingBait = -859384195,
    unkSpMoney = -950624750,
    unkSpMoneyReplace = 1670279562,
    mpMoney = -66088566,
    unkInfoBox = 36547242,
    campTraderInfo = -782493871,
    honorMoneyCards = -2124237476,
    forceSkillCards = 1533515944,
    actionWheelItems = -2106452847
  }