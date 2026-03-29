-- mods unborked:
--   DynamicTraits.2459400130
if type(MoodleType) ~= "table" then return end

local MAP = {
    Angry         = MoodleType.ANGRY,
    Bleeding      = MoodleType.BLEEDING,
    Bored         = MoodleType.BORED,
    CantSprint    = MoodleType.CANT_SPRINT,
    Dead          = MoodleType.DEAD,
    Drunk         = MoodleType.DRUNK,
    Endurance     = MoodleType.ENDURANCE,
    FoodEaten     = MoodleType.FOOD_EATEN,
    HasACold      = MoodleType.HAS_A_COLD,
    HeavyLoad     = MoodleType.HEAVY_LOAD,
    Hungry        = MoodleType.HUNGRY,
    Hyperthermia  = MoodleType.HYPOTHERMIA,
    Hypothermia   = MoodleType.HYPOTHERMIA,
    Injured       = MoodleType.INJURED,
    NoxiousSmell  = MoodleType.NOXIOUS_SMELL,
    Pain          = MoodleType.PAIN,
    Panic         = MoodleType.PANIC,
    Sick          = MoodleType.SICK,
    Stress        = MoodleType.STRESS,
    Thirst        = MoodleType.THIRST,
    Tired         = MoodleType.TIRED,
    Uncomfortable = MoodleType.UNCOMFORTABLE,
    Unhappy       = MoodleType.UNHAPPY,
    Wet           = MoodleType.WET,
    Windchill     = MoodleType.WINDCHILL,
    Zombie        = MoodleType.ZOMBIE,
}

for k, v in pairs(MAP) do
    if MoodleType[k] then
        ZModUnbork.logger:warn("MoodleType.%s already exists", k)
    else
        MoodleType[k] = v
    end
end
