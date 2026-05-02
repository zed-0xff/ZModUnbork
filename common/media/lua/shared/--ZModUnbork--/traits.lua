-- mods unborked:
--   DynamicTraits.2459400130
--   JeevesPC.3693550188
--   Rocky_SanityB42.3390307636

-- TraitFactory was removed in 42.13
if TraitFactory then return end

TraitFactory = {
    -- 42.12 TraitFactory.addTrait()
    -- 42.13 CharacterTrait.register() + CharacterTraitDefinition.addCharacterTraitDefinition()
    addTrait = function(id, name, price, description, is_profession)
        ZModUnbork.log_once("TraitFactory.addTrait('%s', ...)", id)

        local trait = CharacterTrait.register(ZModUnbork.fix_id(id))
        return CharacterTraitDefinition.addCharacterTraitDefinition(trait, name, price, description, is_profession)
    end,

    setMutualExclusive = function(id1, id2)
        local trait1 = CharacterTrait.get(ResourceLocation.of(id1)) or CharacterTrait.get(ResourceLocation.of(ZModUnbork.fix_id(id1)))
        local trait2 = CharacterTrait.get(ResourceLocation.of(id2)) or CharacterTrait.get(ResourceLocation.of(ZModUnbork.fix_id(id2)))
        if trait1 and trait2 then
            ZModUnbork.log_once("TraitFactory.setMutualExclusive('%s', '%s')", id1, id2)
            CharacterTraitDefinition.setMutualExclusive(trait1, trait2)
        else
            ZModUnbork.warn_once("TraitFactory.setMutualExclusive: invalid traits '%s' or '%s'", id1, id2)
        end
    end,

    getTraits = function()
        ZModUnbork.log_once("TraitFactory.getTraits()")
        return CharacterTraitDefinition.getTraits()
    end,
}

-- 42.12: class CharacterTrait
-- 42.13: class CharacterTraitDefinition
zdk.augment_metatable( CharacterTraitDefinition.class, {
    -- 42.12: void addFreeTrait(string)
    -- 42.13: void addGrantedTrait(CharacterTrait)
    addFreeTrait = function(self, id)
        local trait = CharacterTrait.get(ResourceLocation.of(id)) or CharacterTrait.get(ResourceLocation.of(ZModUnbork.fix_id(id)))
        ZModUnbork.log_once("Trait.addFreeTrait('%s') => addGrantedTrait(%s)", id, trait)
        self:addGrantedTrait(trait)
    end,

    -- 42.12: getFreeRecipes
    -- 42.13: getGrantedRecipes
    getFreeRecipes = "getGrantedRecipes",
})

zdk.hook({
    -- 42.12: public void add(String id)
    -- 42.13: public void add(CharacterTrait id)
    [CharacterTraits.class] = {
        add = function(orig, self, id, ...)
            if type(id) == "string" then
                local trait = CharacterTrait.get(ResourceLocation.of(id)) or CharacterTrait.get(ResourceLocation.of(ZModUnbork.fix_id(id)))
                ZModUnbork.log_once("CharacterTraits.add(%s) => %s", id, trait)
                id = trait
            end
            return orig(self, id, ...)
        end,

        remove = function(orig, self, id, ...)
            if type(id) == "string" then
                local trait = CharacterTrait.get(ResourceLocation.of(id)) or CharacterTrait.get(ResourceLocation.of(ZModUnbork.fix_id(id)))
                ZModUnbork.log_once("CharacterTraits.remove(%s) => %s", id, trait)
                id = trait
            end
            return orig(self, id, ...)
        end,
    }
})

-- 42.12: HashMap<PerkFactory.Perk, Integer> Trait.getXPBoostMap()
-- 42.13: HashMap<PerkFactory.Perk, Integer> CharacterTraitDefinition.getXpBoosts()
ZModUnbork.patch_method_alias(CharacterTraitDefinition.class, "getXPBoostMap", "getXpBoosts")

-- 42.12:
--   public boolean HasTrait(TraitCollection.TraitSlot traitSlot)
--   public boolean HasTrait(String str)
--
-- 42.13:
--   public boolean hasTrait(CharacterTrait characterTrait)
--
-- defined in IsoGameCharacter, so all metatables inheriting from it have to be patched
local function patchedHasTrait(self, id)
    local trait = nil
    if type(id) == "string" then
        trait = CharacterTrait.get(ResourceLocation.of(id)) or CharacterTrait.get(ResourceLocation.of(ZModUnbork.fix_id(id)))
    else
        -- CharacterTrait object?
        trait = id
    end

    if not trait then
        ZModUnbork.warn_once("IsoGameCharacter.HasTrait(%s) => nil", id)
        return false
    end

    local result = self:hasTrait(trait)
    ZModUnbork.log_once("IsoGameCharacter.HasTrait(%s) => %s", id, result)
    return result
end

zdk.augment_all_metatables("hasTrait", {
    HasTrait  = patchedHasTrait,
    getTraits = "getCharacterTraits", -- method alias
})

-- JeevesPC.3693550188
zdk.patch_all_metatables('hasTrait', {
    hasTrait = function(orig, self, id, ...)
        if type(id) == "string" then
            local trait = CharacterTrait.get(ResourceLocation.of(id)) or CharacterTrait.get(ResourceLocation.of(ZModUnbork.fix_id(id)))
            ZModUnbork.log_once("hasTrait(%s) => %s", id, trait)
            id = trait
        end
        return orig(self, id, ...)
    end,
})
