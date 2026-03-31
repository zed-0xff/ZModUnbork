-- mods unborked:
--   DynamicTraits.2459400130

-- ProfessionFactory was removed in 42.13
if ProfessionFactory then return end

ProfessionFactory = {
    -- 42.12 ProfessionFactory.addProfession()
    -- 42.13 CharacterProfession.register() + CharacterProfessionDefinition.addCharacterProfessionDefinition()
    addProfession = function(id, name, description, cost)
        ZModUnbork.log_once("ProfessionFactory.addProfession('%s', ...)", id)

        local profType = (
            CharacterProfession.get(ResourceLocation.of(id)) or
            CharacterProfession.get(ResourceLocation.of(ZModUnbork.fix_id(id))) or
            CharacterProfession.register(ZModUnbork.fix_id(id))
        )

        local iconPathName = nil

        local result = (
            CharacterProfessionDefinition.getCharacterProfessionDefinition(profType) or
            CharacterProfessionDefinition.addCharacterProfessionDefinition(profType, name, cost, description, iconPathName)
        )
        return result -- CharacterProfessionDefinition
    end,

    -- 42.12 ProfessionFactory.getProfessions()
    -- 42.13 CharacterProfessionDefinition.getProfessions()
    getProfessions = function()
        ZModUnbork.log_once("ProfessionFactory.getProfessions()")
        return CharacterProfessionDefinition.getProfessions()
    end,

    Reset = function()
        ZModUnbork.log_once("ProfessionFactory.Reset()")
        -- no-op, but required for compatibility with 42.12
    end,
}

-- 42.12: class CharacterProfession
-- 42.13: class CharacterProfessionDefinition
zdk.augment_metatable( CharacterProfessionDefinition.class, {
    -- 42.12: void addFreeTrait(string)
    -- 42.13: void addGrantedTrait(CharacterTrait)
    addFreeTrait = function(self, id)
        local trait = CharacterTrait.get(ResourceLocation.of(id)) or CharacterTrait.get(ResourceLocation.of(ZModUnbork.fix_id(id)))
        ZModUnbork.log_once("Profession.addFreeTrait('%s') => %s", id, trait)
        self:addGrantedTrait(trait)
    end,

    -- 42.12: getFreeRecipes
    -- 42.13: getGrantedRecipes
    getFreeRecipes = function(self)
        ZModUnbork.log_once("Profession.getFreeRecipes()")
        return self:getGrantedRecipes()
    end,
})

zdk.augment_metatable( SurvivorDesc.class, {
    -- 42.12: public string getProfession()
    -- 42.13: public CharacterProfession getCharacterProfession()
    getProfession = function(self)
        ZModUnbork.log_once("SurvivorDesc.getProfession()")
        return self:getCharacterProfession():getName()
    end,
})

-- 42.12: 'doMetalWorkerRecipes = function (metalworker)'
-- 42.13: -
if doMetalWorkerRecipes then return end
function doMetalWorkerRecipes(metalworker)
    ZModUnbork.log_once("doMetalWorkerRecipes(%s)", metalworker.getLabel and metalworker:getLabel() or tostring(metalworker))

    local recipes = CharacterProfessionDefinition.getCharacterProfessionDefinition(CharacterProfession.METALWORKER):getGrantedRecipes()
    for i = 0, recipes:size() - 1 do
        local recipe = recipes:get(i)
        metalworker:addGrantedRecipe(recipe)
    end
end
