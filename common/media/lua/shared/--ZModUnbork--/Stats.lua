-- mods unborked:
--   DynamicTraits.2459400130

-- Endurancelast        = LastEndurance
-- Endurancedanger      = EnduranceDangerWarning (readonly)
-- Endurancewarn        = EnduranceWarning (readonly)
-- StressFromCigarettes = NicotineStress (readonly)
-- Fear                 = none?
--
-- NumVisibleZombies    = exists
-- Tripping             = exists
-- TrippingRotAngle     = exists

local MAP = {
    Anger       = CharacterStat.ANGER,
    Boredom     = CharacterStat.BOREDOM,
    Drunkenness = CharacterStat.INTOXICATION,
    Endurance   = CharacterStat.ENDURANCE,
    Fatigue     = CharacterStat.FATIGUE,
    Fitness     = CharacterStat.FITNESS,
    Hunger      = CharacterStat.HUNGER,
    Idleness    = CharacterStat.IDLENESS,
    Morale      = CharacterStat.MORALE,
    Pain        = CharacterStat.PAIN,
    Panic       = CharacterStat.PANIC,
    Sanity      = CharacterStat.SANITY,
    Sickness    = CharacterStat.SICKNESS,
    Stress      = CharacterStat.STRESS,
    Thirst      = CharacterStat.THIRST,
}

local tbl = {
    getEndurancelast        = "getLastEndurance",
    setEndurancelast        = "setLastEndurance",

    getEndurancedanger      = "getEnduranceDangerWarning",
    setEndurancedanger      = function() end,

    getEndurancewarn        = "getEnduranceWarning",
    setEndurancewarn        = function() end,

    getStressFromCigarettes = "getNicotineStress",
    setStressFromCigarettes = function() end,

    getFear                 = "getPanic", -- XXX not sure
    setFear                 = "setPanic", -- XXX not sure
}

for k, v in pairs(MAP) do
    tbl["get" .. k] = function(self)
        return self:get(v)
    end

    tbl["set" .. k] = function(self, f)
        return self:set(v, f)
    end
end

zdk.augment_metatable( Stats.class, tbl )
