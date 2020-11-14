VehicleEnum = class(Enum)

function VehicleEnum:__init()
    self:EnumInit()

    --[[
CART01
CART02
CART03
CART04
CART05
CART06
CART07
CART08
ARMYSUPPLYWAGON
BUGGY01
BUGGY02
BUGGY03
CHUCKWAGON000X
CHUCKWAGON002X
COACH2
COACH3
COACH4
COACH5
COACH6
coal_wagon
OILWAGON01X
POLICEWAGON01X	Police Patrol Wagon
WAGON02X
WAGON04X
LOGWAGON
WAGON03X
WAGON05X
WAGON06X
WAGONPRISON01X
STAGECOACH001X
STAGECOACH002X
STAGECOACH003X
STAGECOACH004X
STAGECOACH005X
STAGECOACH006X
UTILLIWAG
GATCHUCK
GATCHUCK_2
wagonCircus01x
wagonDairy01x
wagonWork01x
wagonTraveller01x
supplywagon
CABOOSE01X
northpassenger01x
NORTHSTEAMER01X
HANDCART
KEELBOAT
CANOE
CANOETREETRUNK
PIROGUE
RCBOAT
rowboat
ROWBOATSWAMP
SKIFF
SHIP_GUAMA02
SHIP_NBDGUAMA
horseBoat
BREACH_CANNON	Breaching Cannon
GATLING_GUN	Gattling Gun
GATLINGMAXIM02
SMUGGLER02
turbineboat
HOTAIRBALLOON01
hotchkiss_cannon
wagonCircus02x
wagonDoc01x
PIROGUE2
PRIVATECOALCAR01X
PRIVATESTEAMER01X
PRIVATEDINING01X
ROWBOATSWAMP02
midlandboxcar05x
coach3_cutscene
privateflatcar01x
privateboxcar04x
privatebaggage01X
privatepassenger01x
trolley01x
northflatcar01x
supplywagon2
northcoalcar01x
northpassenger03x
privateboxcar02x
armoredcar03x
privateopensleeper02x
WINTERSTEAMER
wintercoalcar
privateboxcar01x
privateobservationcar
privatearmoured
    ]]

    self.HorseBoat = 1
    self:SetDescription(self.HorseBoat, "Horse Boat")

    self.hash_vehicle_map = {
        [GetHashKey("horseBoat")] = self.HorseBoat,
    }

    self.vehicle_hash_map = {}
    for k, v in pairs(self.hash_vehicle_map) do
        self.vehicle_hash_map[v] = k
    end

end

function VehicleEnum:GetFromVehicleHash(vehicle_hash)
    return self.hash_vehicle_map[vehicle_hash]
end

function VehicleEnum:GetVehicleHash(vehicle_enum)
    return self.vehicle_hash_map[vehicle_enum]
end

function VehicleEnum:GetRandomVehicleEnum()
    return random_table_value(self.hash_vehicle_map)
end

VehicleEnum = VehicleEnum()