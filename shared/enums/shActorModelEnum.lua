ActorModelEnum = immediate_class(Enum)

--[[
New agent profile checklist:
1. New entry to ActorModelEnum & hash list
2. New client-side profile
3. New client-side Config file
4. New server-side profile
5. New entry to AgentProfileEnum & update class mapping
6. (optional) New delegator class (& update WaveDelegatorEnum)
7. (optional) New spawn strategy

]]

function ActorModelEnum:__init()
    self:EnumInit()

    self.Deputy = 1
    self:SetDescription(self.Deputy, "Deputy")

    self.Dutch = 2
    self:SetDescription(self.Dutch, "Dutch")

    self.Magnifico = 3
    self:SetDescription(self.Magnifico, "Magnifico")

    self.NudeWoman = 4
    self:SetDescription(self.NudeWoman, "Nude Woman")

    self.KKK = 5
    self:SetDescription(self.KKK, "KKK")

    self.Robot = 6
    self:SetDescription(self.Robot, "Robot")

    self.SwampFreak = 7
    self:SetDescription(self.SwampFreak, "Swamp Freak")

    self.Vampire = 8
    self:SetDescription(self.Vampire, "Vampire")

    self.Wolf = 9
    self:SetDescription(self.Wolf, "Wolf")

    self.Undead = 10
    self:SetDescription(self.Undead, "Undead")

    self.Test = 99
    self:SetDescription(self.Test, "Test")

    -- "U_M_M_SDEXOTICSSHOPKEEPER_01" "CS_MysteriousStranger" "CS_EXOTICCOLLECTOR"
    -- "A_C_Buffalo_Tatanka_01" the boss buffalo
    -- "A_C_Buffalo_01" normal buffalo
    -- "A_C_BoarLegendary_01" a huge boar
    -- "A_C_LionMangy_01" a super fast lion (you're not escaping him)
    -- "A_C_Bull_01" a bull
    -- "A_C_Panther_01" a panther
    -- "A_C_Wolf" a wolf! doggies
    -- snakes: "A_C_Snake_01" "A_C_SnakeBlackTailRattle_01" "A_C_SnakeFerDeLance_01" "A_C_SnakeRedBoa_01"
    -- "CS_Magnifico"
    -- "CS_MysteriousStranger" guy with all grey outfit and grey tophat
    -- "U_F_M_RhdNudeWoman_01" completely nude woman
    -- "CS_crackpotRobot" an actual fucking robot
    -- "CS_FORMYARTBIGWOMAN" a fat woman
    -- "CS_SwampFreak" basically looks like a zombie or monster
    -- "CS_Vampire" vampire
    -- "U_M_M_ValPoopingMan_01" a guy with his pants down and dick&balls out
    -- "RE_RALLY_MALES_01" KKK in black?
    -- "RE_RALLYDISPUTE_MALES_01" KKK !!!!!!
    -- "RE_RALLYSETUP_MALES_01" more KKK !!!!!!
    -- "RE_SAVAGEAFTERMATH_MALES_01" something between a skeleton and a zombie
    -- "RE_SAVAGEAFTERMATH_FEMALES_01" scalped woman with 4 arrows stuck in her LOL
    -- "RE_NAKEDSWIMMER_MALES_01" totally naked man
    -- "RE_DEADBODIES_MALES_01" guy with a disguise on

    if IsClient then
        self.model_hashes = {
            [self.Test] = GetHashKey("CS_crackpotRobot"),
            [self.KKK] = GetHashKey("RE_RALLYDISPUTE_MALES_01"),
            [self.Deputy] = GetHashKey("S_M_M_VALDEPUTY_01"),
            [self.Dutch] = GetHashKey("CS_dutch"),
            [self.Magnifico] = GetHashKey("CS_Magnifico"),
            [self.Robot] = GetHashKey("CS_crackpotRobot"),
            [self.NudeWoman] = GetHashKey("U_F_M_RhdNudeWoman_01"),
            [self.SwampFreak] = GetHashKey("CS_SwampFreak"),
            [self.Vampire] = GetHashKey("CS_Vampire"),
            [self.Wolf] = GetHashKey("A_C_Wolf"),
            [self.Undead] = GetHashKey("RE_SAVAGEAFTERMATH_MALES_01")
            --[self.SwampFreak] = GetHashKey("RE_SAVAGEAFTERMATH_MALES_01")
        }

        Citizen.CreateThread(function()
            Wait(3000)
            for enum_value, ped_model_hash in pairs(self.model_hashes) do
                -- load model
                RequestModel(ped_model_hash)
                while not HasModelLoaded(ped_model_hash) do
                    Citizen.Wait(20)
                end
            end
        end)
    end
end

if IsClient then
    function ActorModelEnum:GetModelHash(actor_model_enum)
        return self.model_hashes[actor_model_enum]
    end

    function ActorModelEnum:GetFromHash(hash)
        for enum_value, group_hash in ipairs(self.model_hashes) do
            if hash == group_hash then
                return enum_value
            end
        end

        return nil
    end
end

ActorModelEnum = ActorModelEnum()