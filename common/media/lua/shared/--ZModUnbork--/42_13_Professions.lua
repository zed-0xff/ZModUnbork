-- mods unborked:
--   CombatMasteringSkill.3435985650
--   DynamicTraits.2459400130
--   LeGourmetRevolution.2719327441 (B41)

-- ProfessionFactory was removed in 42.13
if ProfessionFactory then return end

ProfessionFactory = {
    -- 42.12 ProfessionFactory.addProfession()
    -- 42.13 CharacterProfession.register() + CharacterProfessionDefinition.addCharacterProfessionDefinition()
    addProfession = function(id, name, description, cost)
        ZModUnbork.clog_once('professions', "ProfessionFactory.addProfession(%S, ...)", id)

        local profType = ZModUnbork.RegCache.find_or_create( Registries.CHARACTER_PROFESSION, id )
        if not profType then
            ZModUnbork.warn_once("ProfessionFactory.addProfession(%S) => nil", id)
            return nil
        end
        local iconPathName = nil

        local result = (
            CharacterProfessionDefinition.getCharacterProfessionDefinition(profType) or
            CharacterProfessionDefinition.addCharacterProfessionDefinition(profType, name, cost, description, iconPathName)
        )
        return result -- CharacterProfessionDefinition
    end,

    getProfession = function(id)
        ZModUnbork.clog_once('professions', "ProfessionFactory.getProfession(%s)", id)
        local profType = ZModUnbork.RegCache.find( Registries.CHARACTER_PROFESSION, id )
        if not profType then
            ZModUnbork.warn_once("ProfessionFactory.getProfession(%S) => nil", id)
            return nil
        end
        return CharacterProfessionDefinition.getCharacterProfessionDefinition(profType)
    end,

    -- 42.12 ProfessionFactory.getProfessions()
    -- 42.13 CharacterProfessionDefinition.getProfessions()
    getProfessions = function()
        ZModUnbork.clog_once('professions', "ProfessionFactory.getProfessions()")
        return CharacterProfessionDefinition.getProfessions()
    end,

    Reset = function()
        ZModUnbork.clog_once('professions', "ProfessionFactory.Reset()")
        -- no-op, but required for compatibility with 42.12
    end,
}

-- 42.12: class CharacterProfession
-- 42.13: class CharacterProfessionDefinition
zdk.augment_metatable( CharacterProfessionDefinition.class, {
    -- 42.12: void addFreeTrait(string)
    -- 42.13: void addGrantedTrait(CharacterTrait)
    addFreeTrait = function(self, id)
        local trait = ZModUnbork.RegCache.find(Registries.CHARACTER_TRAIT, id)
        ZModUnbork.clog_once('professions', "Profession.addFreeTrait('%s') => %s", id, trait)
        self:addGrantedTrait(trait)
    end,
})

-- 42.12: Profession.getFreeRecipes()
-- 42.13: CharacterProfessionDefinition.getGrantedRecipes()
ZModUnbork.patch_method_alias(CharacterProfessionDefinition.class, "getFreeRecipes", "getGrantedRecipes")

-- 42.12: HashMap<PerkFactory.Perk, Integer> Profession.getXPBoostMap()
-- 42.13: HashMap<PerkFactory.Perk, Integer> CharacterProfessionDefinition.getXpBoosts()
ZModUnbork.patch_method_alias(CharacterProfessionDefinition.class, "getXPBoostMap", "getXpBoosts")

-- 42.12: public string              SurvivorDesc.getProfession()
-- 42.13: public CharacterProfession SurvivorDesc.getCharacterProfession()
zdk.augment_metatable( SurvivorDesc.class, {
    getProfession = function(self)
        ZModUnbork.clog_once('professions', "SurvivorDesc.getProfession()")
        return self:getCharacterProfession():getName()
    end,
})

-- 42.12: 'doMetalWorkerRecipes = function (metalworker)'
-- 42.13: -
if doMetalWorkerRecipes then return end

function doMetalWorkerRecipes(metalworker)
    ZModUnbork.clog_once('professions', "doMetalWorkerRecipes(%s)", metalworker.getLabel and metalworker:getLabel() or tostring(metalworker))

    local recipes = CharacterProfessionDefinition.getCharacterProfessionDefinition(CharacterProfession.METALWORKER):getGrantedRecipes()
    for i = 0, recipes:size() - 1 do
        local recipe = recipes:get(i)
        metalworker:addGrantedRecipe(recipe)
    end
end
