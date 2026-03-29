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
    getEndurancelast        = function(self)    return self:getLastEndurance() end,
    setEndurancelast        = function(self, f) return self:setLastEndurance(f) end,

    getEndurancedanger      = function(self)    return self:getEnduranceDangerWarning() end,
    setEndurancedanger      = function() end,

    getEndurancewarn        = function(self)    return self:getEnduranceWarning() end,
    setEndurancewarn        = function() end,

    getStressFromCigarettes = function(self)    return self:getNicotineStress() end,
    setStressFromCigarettes = function() end,

    getFear                 = function(self)    return self:getPanic() end,  -- XXX not sure
    setFear                 = function(self, f) return self:setPanic(f) end, -- XXX not sure
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
