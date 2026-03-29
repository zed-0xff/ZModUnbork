-- mods unborked:
--   Anthro Survivors (the "Furry Mod")
--   Furry Apocalypse (Anthro Zombies)
--   Rocky_SanityB42.3390307636
--   Support Goods - MyComputers

if not BodyDamage or not CharacterStat then return end

local MAP = {
    BoredomLevel      = CharacterStat.BOREDOM,
    DiscomfortLevel   = CharacterStat.DISCOMFORT,
    FoodSicknessLevel = CharacterStat.FOOD_SICKNESS,
    InfectionLevel    = CharacterStat.ZOMBIE_INFECTION,
    PoisonLevel       = CharacterStat.POISON,
    Temperature       = CharacterStat.TEMPERATURE,
    UnhappynessLevel  = CharacterStat.UNHAPPINESS,
    Wetness           = CharacterStat.WETNESS,
}

-- get/set FakeInfectionLevel - not in 42.13

local tbl = {}
for k, v in pairs(MAP) do
    tbl["get" .. k] = function(self)
        return self:getParentChar():getStats():get(v)
    end

    tbl["set" .. k] = function(self, f)
        return self:getParentChar():getStats():set(v, f)
    end
end

zdk.augment_metatable( BodyDamage.class, tbl )
