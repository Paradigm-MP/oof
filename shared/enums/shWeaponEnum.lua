WeaponEnum = class(Enum)

function WeaponEnum:__init()
    self:EnumInit()


    self.MoonshineJug = 1
    self:SetDescription(self.MoonshineJug, "Moonshine Jug")
    
    self.ElectricLantern = 2
    self:SetDescription(self.ElectricLantern, "Electric Lantern")
    
    self.Torch = 3
    self:SetDescription(self.Torch, "Torch")

    self.BrokenSword = 4
    self:SetDescription(self.BrokenSword, "Broken Sword")

    self.FishingRod = 5
    self:SetDescription(self.FishingRod, "Fishing Rod")

    self.Hatchet = 6
    self:SetDescription(self.Hatchet, "Hatchet")

    self.Cleaver = 7
    self:SetDescription(self.Cleaver, "Cleaver")

    self.AncientHatchet = 8
    self:SetDescription(self.AncientHatchet, "Ancient Hatchet")

    self.VikingHatchet = 9
    self:SetDescription(self.VikingHatchet, "Viking Hatchet")

    self.HewingHatchet = 10
    self:SetDescription(self.HewingHatchet, "Hewing Hatchet")

    self.DoubleBitHatchet = 11
    self:SetDescription(self.DoubleBitHatchet, "Double Bit Hatchet")

    self.DoubleBitRustedHatchet = 12
    self:SetDescription(self.DoubleBitRustedHatchet, "Double Bit Rusted Hatchet")

    self.HunterHatchet = 13
    self:SetDescription(self.HunterHatchet, "Hunter Hatchet")

    self.RustedHunterHatchet = 14
    self:SetDescription(self.RustedHunterHatchet, "Rusted Hunter Hatchet")

    self.KnifeJohn = 15
    self:SetDescription(self.KnifeJohn, "John Knife")

    self.Knife = 16
    self:SetDescription(self.Knife, "Knife")

    self.KnifeJawbone = 17
    self:SetDescription(self.KnifeJawbone, "Jawbone Knife")

    self.ThrowingKnife = 18
    self:SetDescription(self.ThrowingKnife, "Throwing Knife")

    self.KnifeMiner = 19
    self:SetDescription(self.KnifeMiner, "Miner Knife")

    self.KnifeCivilWar = 20
    self:SetDescription(self.KnifeCivilWar, "Civil War Knife")

    self.KnifeBear = 21
    self:SetDescription(self.KnifeBear, "Bear Knife")

    self.KnifeVampire = 22
    self:SetDescription(self.KnifeVampire, "Vampire Knife")

    self.Machete = 23
    self:SetDescription(self.Machete, "Machete")

    self.Tomahawk = 24
    self:SetDescription(self.Tomahawk, "Tomahawk")

    self.TomahawkAncient = 25
    self:SetDescription(self.TomahawkAncient, "Ancient Tomahawk")

    self.PistolMauser = 26
    self:SetDescription(self.PistolMauser, "Mauser Pistol")

    self.PistolSemiauto = 27
    self:SetDescription(self.PistolSemiauto, "Semi-Automatic Pistol")

    self.PistolVolcanic = 28
    self:SetDescription(self.PistolVolcanic, "Volcanic Pistol")

    self.RepeaterCarbine = 29
    self:SetDescription(self.RepeaterCarbine, "Carbine Repeater")

    self.RepeaterHenry = 30
    self:SetDescription(self.RepeaterHenry, "Henry Repeater")

    self.RifleVarmint = 31
    self:SetDescription(self.RifleVarmint, "Varmint Rifle")

    self.RepeaterWinchester = 32
    self:SetDescription(self.RepeaterWinchester, "Winchester Repeater")

    self.RevolverCattleman = 33
    self:SetDescription(self.RevolverCattleman, "Cattleman Revolver")

    self.RevolverDoubleAction = 34
    self:SetDescription(self.RevolverDoubleAction, "Double-Action Revolver")

    self.RevolverLemat = 35
    self:SetDescription(self.RevolverLemat, "Lemat Revolver")

    self.RevolverSchofield = 36
    self:SetDescription(self.RevolverSchofield, "Schofield Revolver")

    self.RifleBoltaction = 37
    self:SetDescription(self.RifleBoltaction, "Bolt-Action Rifle")

    self.SniperRifleCarcano = 38
    self:SetDescription(self.SniperRifleCarcano, "Carcano Sniper Rifle")

    self.SniperRifleRollingBlock = 39
    self:SetDescription(self.SniperRifleRollingBlock, "Rolling Block Sniper Rifle")

    self.RifleSpringField = 40
    self:SetDescription(self.RifleSpringField, "Springfield Rifle")

    self.ShotgunDoublebarrel = 41
    self:SetDescription(self.ShotgunDoublebarrel, "Double-Barrel Shotgun")

    self.ShotgunPump = 42
    self:SetDescription(self.ShotgunPump, "Pump Shotgun")

    self.ShotgunRepeating = 43
    self:SetDescription(self.ShotgunRepeating, "Repeating Shotgun")

    self.ShotgunSawedoff = 44
    self:SetDescription(self.ShotgunSawedoff, "Sawed-Off Shotgun")

    self.ShotgunSemiauto = 45
    self:SetDescription(self.ShotgunSemiauto, "Semi-Automatic Shotgun")

    self.Bow = 46
    self:SetDescription(self.Bow, "Bow")

    self.Dynamite = 47
    self:SetDescription(self.Dynamite, "Dynamite")
    
    self.Molotov = 48
    self:SetDescription(self.Molotov, "Molotov")

    self.hash_weapon_map = {
        [GetHashKey("WEAPON_MOONSHINEJUG")] = self.MoonshineJug,
        [GetHashKey("WEAPON_MELEE_LANTERN_ELECTRIC")] = self.ElectricLantern,
        [GetHashKey("WEAPON_MELEE_TORCH")] = self.Torch,
        [GetHashKey("WEAPON_MELEE_BROKEN_SWORD")] = self.BrokenSword,
        [GetHashKey("WEAPON_FISHINGROD")] = self.FishingRod,
        [GetHashKey("WEAPON_MELEE_HATCHET")] = self.Hatchet,
        [GetHashKey("WEAPON_MELEE_CLEAVER")] = self.Cleaver,
        [GetHashKey("WEAPON_MELEE_ANCIENT_HATCHET")] = self.AncientHatchet,
        [GetHashKey("WEAPON_MELEE_HATCHET_VIKING")] = self.VikingHatchet,
        [GetHashKey("WEAPON_MELEE_HATCHET_HEWING")] = self.HewingHatchet,
        [GetHashKey("WEAPON_MELEE_HATCHET_DOUBLE_BIT")] = self.DoubleBitHatchet,
        [GetHashKey("WEAPON_MELEE_HATCHET_DOUBLE_BIT_RUSTED")] = self.DoubleBitRustedHatchet,
        [GetHashKey("WEAPON_MELEE_HATCHET_HUNTER")] = self.HunterHatchet,
        [GetHashKey("WEAPON_MELEE_HATCHET_HUNTER_RUSTED")] = self.RustedHunterHatchet,
        [GetHashKey("WEAPON_MELEE_KNIFE_JOHN")] = self.KnifeJohn,
        [GetHashKey("WEAPON_MELEE_KNIFE")] = self.Knife,
        [GetHashKey("WEAPON_MELEE_KNIFE_JAWBONE")] = self.KnifeJawbone,
        [GetHashKey("WEAPON_THROWN_THROWING_KNIVES")] = self.ThrowingKnife,
        [GetHashKey("WEAPON_MELEE_KNIFE_MINER")] = self.KnifeMiner,
        [GetHashKey("WEAPON_MELEE_KNIFE_CIVIL_WAR")] = self.KnifeCivilWar,
        [GetHashKey("WEAPON_MELEE_KNIFE_BEAR")] = self.KnifeBear,
        [GetHashKey("WEAPON_MELEE_KNIFE_VAMPIRE")] = self.KnifeVampire,
        [GetHashKey("WEAPON_MELEE_MACHETE")] = self.Machete,
        [GetHashKey("WEAPON_THROWN_TOMAHAWK")] = self.Tomahawk,
        [GetHashKey("WEAPON_THROWN_TOMAHAWK_ANCIENT")] = self.TomahawkAncient,
        [GetHashKey("WEAPON_PISTOL_MAUSER")] = self.PistolMauser,
        [GetHashKey("WEAPON_PISTOL_SEMIAUTO")] = self.PistolSemiauto,
        [GetHashKey("WEAPON_PISTOL_VOLCANIC")] = self.PistolVolcanic,
        [GetHashKey("WEAPON_REPEATER_CARBINE")] = self.RepeaterCarbine,
        [GetHashKey("WEAPON_REPEATER_HENRY")] = self.RepeaterHenry,
        [GetHashKey("WEAPON_RIFLE_VARMINT")] = self.RifleVarmint,
        [GetHashKey("WEAPON_REPEATER_WINCHESTER")] = self.RepeaterWinchester,
        [GetHashKey("WEAPON_REVOLVER_CATTLEMAN")] = self.RevolverCattleman,
        [GetHashKey("WEAPON_REVOLVER_DOUBLEACTION")] = self.RevolverDoubleAction,
        [GetHashKey("WEAPON_REVOLVER_LEMAT")] = self.RevolverLemat,
        [GetHashKey("WEAPON_REVOLVER_SCHOFIELD")] = self.RevolverSchofield,
        [GetHashKey("WEAPON_RIFLE_BOLTACTION")] = self.RifleBoltaction,
        [GetHashKey("WEAPON_SNIPERRIFLE_CARCANO")] = self.SniperRifleCarcano,
        [GetHashKey("WEAPON_SNIPERRIFLE_ROLLINGBLOCK")] = self.SniperRifleRollingBlock,
        [GetHashKey("WEAPON_RIFLE_SPRINGFIELD")] = self.RifleSpringField,
        [GetHashKey("WEAPON_SHOTGUN_DOUBLEBARREL")] = self.ShotgunDoublebarrel,
        [GetHashKey("WEAPON_SHOTGUN_PUMP")] = self.ShotgunPump,
        [GetHashKey("WEAPON_SHOTGUN_REPEATING")] = self.ShotgunRepeating,
        [GetHashKey("WEAPON_SHOTGUN_SAWEDOFF")] = self.ShotgunSawedoff,
        [GetHashKey("WEAPON_SHOTGUN_SEMIAUTO")] = self.ShotgunSemiauto,
        [GetHashKey("WEAPON_BOW")] = self.Bow,
        [GetHashKey("WEAPON_THROWN_DYNAMITE")] = self.Dynamite,
        [GetHashKey("WEAPON_THROWN_MOLOTOV")] = self.Molotov
    }

    self.weapon_hash_map = {
        [self.MoonshineJug] = GetHashKey("WEAPON_MOONSHINEJUG"),
        [self.ElectricLantern] = GetHashKey("WEAPON_MELEE_LANTERN_ELECTRIC"),
        [self.Torch] = GetHashKey("WEAPON_MELEE_TORCH"),
        [self.BrokenSword] = GetHashKey("WEAPON_MELEE_BROKEN_SWORD"),
        [self.FishingRod] = GetHashKey("WEAPON_FISHINGROD"),
        [self.Hatchet] = GetHashKey("WEAPON_MELEE_HATCHET"),
        [self.Cleaver] = GetHashKey("WEAPON_MELEE_CLEAVER"),
        [self.AncientHatchet] = GetHashKey("WEAPON_MELEE_ANCIENT_HATCHET"),
        [self.VikingHatchet] = GetHashKey("WEAPON_MELEE_HATCHET_VIKING"),
        [self.HewingHatchet] = GetHashKey("WEAPON_MELEE_HATCHET_HEWING"),
        [self.DoubleBitHatchet] = GetHashKey("WEAPON_MELEE_HATCHET_DOUBLE_BIT"),
        [self.DoubleBitRustedHatchet] = GetHashKey("WEAPON_MELEE_HATCHET_DOUBLE_BIT_RUSTED"),
        [self.HunterHatchet] = GetHashKey("WEAPON_MELEE_HATCHET_HUNTER"),
        [self.RustedHunterHatchet] = GetHashKey("WEAPON_MELEE_HATCHET_HUNTER_RUSTED"),
        [self.KnifeJohn] = GetHashKey("WEAPON_MELEE_KNIFE_JOHN"),
        [self.Knife] = GetHashKey("WEAPON_MELEE_KNIFE"),
        [self.KnifeJawbone] = GetHashKey("WEAPON_MELEE_KNIFE_JAWBONE"),
        [self.ThrowingKnife] = GetHashKey("WEAPON_THROWN_THROWING_KNIVES"),
        [self.KnifeMiner] = GetHashKey("WEAPON_MELEE_KNIFE_MINER"),
        [self.KnifeCivilWar] = GetHashKey("WEAPON_MELEE_KNIFE_CIVIL_WAR"),
        [self.KnifeBear] = GetHashKey("WEAPON_MELEE_KNIFE_BEAR"),
        [self.KnifeVampire] = GetHashKey("WEAPON_MELEE_KNIFE_VAMPIRE"),
        [self.Machete] = GetHashKey("WEAPON_MELEE_MACHETE"),
        [self.Tomahawk] = GetHashKey("WEAPON_THROWN_TOMAHAWK"),
        [self.TomahawkAncient] = GetHashKey("WEAPON_THROWN_TOMAHAWK_ANCIENT"),
        [self.PistolMauser] = GetHashKey("WEAPON_PISTOL_MAUSER"),
        [self.PistolSemiauto] = GetHashKey("WEAPON_PISTOL_SEMIAUTO"),
        [self.PistolVolcanic] = GetHashKey("WEAPON_PISTOL_VOLCANIC"),
        [self.RepeaterCarbine] = GetHashKey("WEAPON_REPEATER_CARBINE"),
        [self.RepeaterHenry] = GetHashKey("WEAPON_REPEATER_HENRY"),
        [self.RifleVarmint] = GetHashKey("WEAPON_RIFLE_VARMINT"),
        [self.RepeaterWinchester] = GetHashKey("WEAPON_REPEATER_WINCHESTER"),
        [self.RevolverCattleman] = GetHashKey("WEAPON_REVOLVER_CATTLEMAN"),
        [self.RevolverDoubleAction] = GetHashKey("WEAPON_REVOLVER_DOUBLEACTION"),
        [self.RevolverLemat] = GetHashKey("WEAPON_REVOLVER_LEMAT"),
        [self.RevolverSchofield] = GetHashKey("WEAPON_REVOLVER_SCHOFIELD"),
        [self.RifleBoltaction] = GetHashKey("WEAPON_RIFLE_BOLTACTION"),
        [self.SniperRifleCarcano] = GetHashKey("WEAPON_SNIPERRIFLE_CARCANO"),
        [self.SniperRifleRollingBlock] = GetHashKey("WEAPON_SNIPERRIFLE_ROLLINGBLOCK"),
        [self.RifleSpringField] = GetHashKey("WEAPON_RIFLE_SPRINGFIELD"),
        [self.ShotgunDoublebarrel] = GetHashKey("WEAPON_SHOTGUN_DOUBLEBARREL"),
        [self.ShotgunPump] = GetHashKey("WEAPON_SHOTGUN_PUMP"),
        [self.ShotgunRepeating] = GetHashKey("WEAPON_SHOTGUN_REPEATING"),
        [self.ShotgunSawedoff] = GetHashKey("WEAPON_SHOTGUN_SAWEDOFF"),
        [self.ShotgunSemiauto] = GetHashKey("WEAPON_SHOTGUN_SEMIAUTO"),
        [self.Bow] = GetHashKey("WEAPON_BOW"),
        [self.Dynamite] = GetHashKey("WEAPON_THROWN_DYNAMITE"),
        [self.Molotov] = GetHashKey("WEAPON_THROWN_MOLOTOV")
    }

    self.weapon_model_map = {
        [self.MoonshineJug] = {"s_interact_jug_pickup"},
        [self.ElectricLantern] = {"s_interact_lantern03x_pickup"},
        [self.Torch] = {"s_interact_torch"},
        [self.BrokenSword] = {"w_melee_brokenSword01"},
        [self.FishingRod] = {"w_melee_fishingpole02"},
        [self.Hatchet] = {"w_melee_hatchet01"},
        [self.Cleaver] = {"w_melee_hatchet02"},
        [self.AncientHatchet] = {"w_melee_hatchet03"},
        [self.VikingHatchet] = {"w_melee_hatchet04"},
        [self.HewingHatchet] = {"w_melee_hatchet05"},
        [self.DoubleBitHatchet] = {"w_melee_hatchet06"},
        [self.DoubleBitRustedHatchet] = {"w_melee_hatchet06"},
        [self.HunterHatchet] = {"w_melee_hatchet07"},
        [self.RustedHunterHatchet] = {"w_melee_hatchet07"},
        [self.KnifeJohn] = {"w_melee_knife01"},
        [self.Knife] = {"w_melee_knife02"},
        [self.KnifeJawbone] = {"w_melee_knife03"},
        [self.ThrowingKnife] = {"w_melee_knife05"},
        [self.KnifeMiner] = {"w_melee_knife14"},
        [self.KnifeCivilWar] = {"w_melee_knife16"},
        [self.KnifeBear] = {"w_melee_knife17"},
        [self.KnifeVampire] = {"w_melee_knife18"},
        [self.Machete] = {"w_melee_machete01"},
        [self.Tomahawk] = {"w_melee_tomahawk01"},
        [self.TomahawkAncient] = {"w_melee_tomahawk02"},
        [self.PistolMauser] = {
            "w_pistol_mauser01",
            "w_pistol_mauser01_barrel1",
            --"w_pistol_mauser01_barrel2",
            "w_pistol_mauser01_clip",
            --"w_pistol_mauser01_clip2",
            "w_pistol_mauser01_grip1",
            --"w_pistol_mauser01_grip2",
            --"w_pistol_mauser01_grip3",
            --"w_pistol_mauser01_grip4",
            "w_pistol_mauser01_sight1",
            --"w_pistol_mauser01_sight2"
        },
        [self.PistolSemiauto] = {
            "w_pistol_semiauto01",
            "w_pistol_semiauto01_barrel1",
            --"w_pistol_semiauto01_barrel2",
            "w_pistol_semiauto01_clip",
            "w_pistol_semiauto01_grip1",
            --"w_pistol_semiauto01_grip2",
            --"w_pistol_semiauto01_grip3",
            --"w_pistol_semiauto01_grip4",
            "w_pistol_semiauto01_sight1",
            --"w_pistol_semiauto01_sight2"
        },
        [self.PistolVolcanic] = {
            "w_pistol_volcanic01",
            "w_pistol_volcanic01_barrel01",
            --"w_pistol_volcanic01_barrel02",
            "w_pistol_volcanic01_grip1",
            --"w_pistol_volcanic01_grip2",
            --"w_pistol_volcanic01_grip3",
            --"w_pistol_volcanic01_grip4",
            "w_pistol_volcanic01_sight1",
            --"w_pistol_volcanic01_sight2"
        },
        [self.RepeaterCarbine] = {
            "W_REPEATER_CARBINE01",
            "w_repeater_carbine01_clip1",
            "w_repeater_carbine01_grip1",
            --"w_repeater_carbine01_grip2",
            --"w_repeater_carbine01_grip3",
            "w_repeater_carbine01_sight1",
            --"w_repeater_carbine01_sight2",
            "w_repeater_carbine01_wrap1",
            --"w_repeater_carbine01_wrap2"
        },
        [self.RepeaterHenry] = {
            "w_repeater_henry01",
            "w_repeater_henry01_grip1",
            --"w_repeater_henry01_grip2",
            --"w_repeater_henry01_grip3",
            "w_repeater_henry01_sight1",
            --"w_repeater_henry01_sight2",
            --"w_repeater_henry01_wrap1",
            --"w_repeater_henry01_wrap2"
        },
        [self.RifleVarmint] = {
            "w_repeater_pumpaction01",
            "w_repeater_pumpaction01_clip1",
            --"w_repeater_pumpaction01_clip2",
            --"w_repeater_pumpaction01_clip3",
            "w_repeater_pumpaction01_grip1",
            --"w_repeater_pumpaction01_grip2",
            --"w_repeater_pumpaction01_grip3",
            "w_repeater_pumpaction01_sight1",
            --"w_repeater_pumpaction01_sight2",
            --"w_repeater_pumpaction01_wrap1",
            --"w_repeater_pumpaction01_wrap2"
        },
        [self.RepeaterWinchester] = {
            "w_repeater_winchester01",
            "w_repeater_winchester01_bullet",
            "w_repeater_winchester01_grip1",
            --"w_repeater_winchester01_grip2",
            --"w_repeater_winchester01_grip3",
            "w_repeater_winchester01_sight1",
            --"w_repeater_winchester01_sight2",
            --"w_repeater_winchester01_wrap1",
            --"w_repeater_winchester01_wrap2"
        },
        [self.RevolverCattleman] = {
            "w_revolver_cattleman01",
            "w_revolver_cattleman01_barrel01",
            --"w_revolver_cattleman01_barrel02",
            "w_revolver_cattleman01_grip1",
            --"w_revolver_cattleman01_grip2",
            --"w_revolver_cattleman01_grip3",
            --"w_revolver_cattleman01_grip4",
            --"w_revolver_cattleman01_grip5",
            "w_revolver_cattleman01_sight1",
            --"w_revolver_cattleman01_sight2"
        },
        [self.RevolverDoubleAction] = {
            "w_revolver_doubleaction01",
            "w_revolver_doubleaction01_barrel01",
            --"w_revolver_doubleaction01_barrel02",
            "w_revolver_doubleaction01_grip1",
            --"w_revolver_doubleaction01_grip2",
            --"w_revolver_doubleaction01_grip3",
            --"w_revolver_doubleaction01_grip4",
            --"w_revolver_doubleaction01_grip5",
            "w_revolver_doubleaction01_sight1",
            --"w_revolver_doubleaction01_sight2"
        },
        [self.RevolverLemat] = {
            "w_revolver_lemat01",
            "w_revolver_lemat01_barrel01",
            --"w_revolver_lemat01_barrel02",
            "w_revolver_lemat01_grip1",
            --"w_revolver_lemat01_grip2",
            --"w_revolver_lemat01_grip3",
            --"w_revolver_lemat01_grip4",
            "w_revolver_lemat01_sight1",
            --"w_revolver_lemat01_sight2"
        },
        [self.RevolverSchofield] = {
            "w_revolver_schofield01",
            "w_revolver_schofield01_barrel01",
            --"w_revolver_schofield01_barrel02",
            "w_revolver_schofield01_grip1",
            --"w_revolver_schofield01_grip2",
            --"w_revolver_schofield01_grip3",
            --"w_revolver_schofield01_grip4",
            "w_revolver_schofield01_sight1",
            --"w_revolver_schofield01_sight2"
        },
        [self.RifleBoltaction] = {
            "w_rifle_boltaction01",
            "w_rifle_boltaction01_grip1",
            --"w_rifle_boltaction01_grip2",
            --"w_rifle_boltaction01_grip3",
            "w_rifle_boltaction01_sight1",
            --"w_rifle_boltaction01_sight2",
            --"w_rifle_boltaction01_wrap1",
            --"w_rifle_boltaction01_wrap2"
        },
        [self.SniperRifleCarcano] = {
            "W_RIFLE_CARCANO01",
            "w_rifle_carcano01_clip",
            --"w_rifle_carcano01_clip2",
            "w_rifle_carcano01_grip1",
            --"w_rifle_carcano01_grip2",
            --"w_rifle_carcano01_grip3",
            "w_rifle_carcano01_sight1",
            --"w_rifle_carcano01_sight2",
            --"w_rifle_carcano01_wrap1",
            --"w_rifle_carcano01_wrap2"
        },
        [self.SniperRifleRollingBlock] = {
            "w_rifle_rollingblock01",
            "w_rifle_rollingblock01_grip1",
            --"w_rifle_rollingblock01_grip2",
            --"w_rifle_rollingblock01_grip3",
            "w_rifle_rollingblock01_sight1",
            --"w_rifle_rollingblock01_sight2",
            --"w_rifle_rollingblock01_wrap1",
            --"w_rifle_rollingblock01_wrap2"
        },
        [self.RifleSpringField] = {
            "w_rifle_springfield01",
            "w_rifle_springfield01_grip1",
            --"w_rifle_springfield01_grip2",
            --"w_rifle_springfield01_grip3",
            "w_rifle_springfield01_sight1",
            --"w_rifle_springfield01_sight2",
            --"w_rifle_springfield01_wrap1",
            --"w_rifle_springfield01_wrap2"
        },
        [self.ShotgunDoublebarrel] = {
            "w_shotgun_doublebarrel01",
            "w_shotgun_doublebarrel01_barrel1",
            --"w_shotgun_doublebarrel01_barrel2",
            "w_shotgun_doublebarrel01_grip1",
            --"w_shotgun_doublebarrel01_grip2",
            --"w_shotgun_doublebarrel01_grip3",
            "w_shotgun_doublebarrel01_mag1",
            --"w_shotgun_doublebarrel01_mag2",
            --"w_shotgun_doublebarrel01_mag3",
            "w_shotgun_doublebarrel01_sight1",
            --"w_shotgun_doublebarrel01_sight2",
            --"w_shotgun_doublebarrel01_wrap1",
            --"w_shotgun_doublebarrel01_wrap2"
        },
        [self.ShotgunPump] = {
            "w_shotgun_pumpaction01",
            "w_shotgun_pumpaction01_barrel1",
            --"w_shotgun_pumpaction01_barrel2",
            "w_shotgun_pumpaction01_clip1",
            --"w_shotgun_pumpaction01_clip2",
            --"w_shotgun_pumpaction01_clip3",
            "w_shotgun_pumpaction01_grip1",
            --"w_shotgun_pumpaction01_grip2",
            --"w_shotgun_pumpaction01_grip3",
            "w_shotgun_pumpaction01_sight1",
            --"w_shotgun_pumpaction01_sight2",
            --"w_shotgun_pumpaction01_wrap1",
            --"w_shotgun_pumpaction01_wrap2"
        },
        [self.ShotgunRepeating] = {
            "w_shotgun_repeating01",
            "w_shotgun_repeating01_barrel1",
            --"w_shotgun_repeating01_barrel2",
            "w_shotgun_repeating01_grip1",
            --"w_shotgun_repeating01_grip2",
            --"w_shotgun_repeating01_grip3",
            "w_shotgun_repeating01_sight1",
            --"w_shotgun_repeating01_sight2",
            --"w_shotgun_repeating01_wrap1",
            --"w_shotgun_repeating01_wrap2"
        },
        [self.ShotgunSawedoff] = {
            "w_shotgun_sawed01",
            "w_shotgun_sawed01_grip1",
            --"w_shotgun_sawed01_grip2",
            --"w_shotgun_sawed01_grip3",
            "w_shotgun_sawed01_sight1",
            --"w_shotgun_sawed01_sight2",
            "w_shotgun_sawed01_stock1",
            --"w_shotgun_sawed01_stock2",
            --"w_shotgun_sawed01_stock3",
            --"w_shotgun_sawed01_wrap1",
            --"w_shotgun_sawed01_wrap2"
        },
        [self.ShotgunSemiauto] = {
            "w_shotgun_semiauto01",
            "w_shotgun_semiauto01_barrel1",
            --"w_shotgun_semiauto01_barrel2",
            "w_shotgun_semiauto01_grip1",
            --"w_shotgun_semiauto01_grip2",
            --"w_shotgun_semiauto01_grip3",
            "w_shotgun_semiauto01_sight1",
            --"w_shotgun_semiauto01_sight2",
            --"w_shotgun_semiauto01_wrap1",
            --"w_shotgun_semiauto01_wrap2"
        },
        [self.Bow] = {"W_SP_BowArrow"},
        [self.Dynamite] = {"w_throw_dynamite01"},
        [self.Molotov] = {"w_throw_molotov01"}
    }

end

function WeaponEnum:GetFromWeaponHash(weapon_hash)
    return self.hash_weapon_map[weapon_hash]
end

function WeaponEnum:GetWeaponHash(weapon_enum)
    return self.weapon_hash_map[weapon_enum]
end

function WeaponEnum:GetWeaponModel(weapon_enum)
    -- Yeah, apparently there was a native for this
    --return GetWeapontypeModel(self:GetWeaponHash(weapon_enum))
    return self.weapon_model_map[weapon_enum]
end

function WeaponEnum:GetRandomWeaponEnum()
    return random_table_value(self.hash_weapon_map)
end

WeaponEnum = WeaponEnum()