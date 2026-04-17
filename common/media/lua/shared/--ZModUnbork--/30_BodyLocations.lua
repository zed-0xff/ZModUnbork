-- unborked mods:
--   FortniteFurryGirls
--   Furry
--   newcontainers_B42.3535295548
--   SoftAndGentleHoodie.3371049128

if getCore():getGameVersion():isLessThan(GameVersion.parse("42.13")) then return end

local logger = ZModUnbork.logger
local _locations_registry = ZModUnbork.RegCache.get(Registries.ITEM_BODY_LOCATION)

local function convert_id(id, fmt, ...)
    if fmt then ZModUnbork.log_once(fmt, ...) end
    return ZModUnbork.RegCache.convert_id(Registries.ITEM_BODY_LOCATION, id)
end

zdk.hook({
    -- zombie/characters/WornItems/BodyLocationGroup.java
    [BodyLocationGroup.class] = {
        --   41.78
        --     public BodyLocation getOrCreateLocation(String id)
        --
        --   42.12
        --     public BodyLocation getOrCreateLocation(ItemBodyLocation id)
        --     public BodyLocation getOrCreateLocation(String id)
        --
        --   42.13.1
        --     public BodyLocation getOrCreateLocation(ItemBodyLocation id)
        getOrCreateLocation = function(orig, self, id, ...)
            if type(id) == "string" then id = convert_id(id, "BodyLocationGroup.getOrCreateLocation('%s')", id) end
            return orig(self, id, ...)
        end,

        -- 42.12: public int indexOf(String id)
        -- 42.13: public int indexOf(ItemBodyLocation id)
        indexOf = function(orig, self, id, ...)
            if type(id) == "string" then id = convert_id(id, "BodyLocationGroup.indexOf('%s')", id) end
            return orig(self, id, ...)
        end,

        -- 42.12: public void setHideModel(String id1, String id2)
        -- 42.13: public void setHideModel(ItemBodyLocation id1, ItemBodyLocation id2)
        setHideModel = function(orig, self, id1, id2, ...)
            if type(id1) == "string" then id1 = convert_id(id1, "BodyLocationGroup.setHideModel('%s', '%s')", id1, id2) end
            if type(id2) == "string" then id2 = convert_id(id2, "BodyLocationGroup.setHideModel('%s', '%s')", id1, id2) end
            return orig(self, id1, id2, ...)
        end,

        -- 42.12: public void setExclusive(String id1, String id2)
        -- 42.13: public void setExclusive(ItemBodyLocation id1, ItemBodyLocation id2)
        setExclusive = function(orig, self, id1, id2, ...)
            if type(id1) == "string" then id1 = convert_id(id1, "BodyLocationGroup.setExclusive('%s', '%s')", id1, id2) end
            if type(id2) == "string" then id2 = convert_id(id2, "BodyLocationGroup.setExclusive('%s', '%s')", id1, id2) end
            return orig(self, id1, id2, ...)
        end,
    },

    -- zombie/characters/WornItems/BodyLocation.java
    BodyLocation = {
        -- 42.12: public BodyLocation(BodyLocationGroup group, String id)
        -- 42.13: public BodyLocation(BodyLocationGroup group, ItemBodyLocation id)
        new = function(orig, group, id, ...)
            ZModUnbork.last_group = group -- used in FurryMod_fix.lua
            if type(id) == "string" then id = convert_id(id, "BodyLocation.new(%s, '%s')", group, id) end
            return orig(group, id, ...)
        end,
    },
})

-- SurvivorDesc, IsoGameCharacter, IsoPlayer that inherits from IsoGameCharacter:
--   42.12: public void setWornItem(String str, InventoryItem inventoryItem)
--   42.13: public void setWornItem(ItemBodyLocation itemBodyLocation, InventoryItem item)
zdk.patch_all_metatables('setWornItem', {
    setWornItem = function(orig, self, loc, item, ...)
        if not loc then
            ZModUnbork.warn_once("setWornItem called with nil loc for %s", self)
            return
        end
        if type(loc) == "string" then loc = convert_id(loc, "setWornItem('%s')", loc) end
        return orig(self, loc, item, ...)
    end
})

local function checkItem(item, phase)
    if not item.getBodyLocation or not item.setBodyLocation then return end
    if item:getBodyLocation() then return end -- already fixed

    local scriptTbl = zdk.parse_item_script(item)
    if not scriptTbl or not scriptTbl.bodylocation then return end

    local newLoc = _locations_registry[scriptTbl.bodylocation:lower()]
    if newLoc then
        logger:info("set %-13s to %-35s for %s", "bodyLocation", newLoc, item:getFullName())
        item:setBodyLocation(newLoc)
    elseif phase == 2 then
        logger:warn("phase%s: unknown bodyLocation %-20s for %s", phase, scriptTbl.bodylocation, item:getFullName())
    end
end

local function tableKeys(tbl)
    local keys = {}
    for k in pairs(tbl) do table.insert(keys, k) end
    return keys
end

-- ClothingSelectionDefinitions.default.Female = {
--   Legging -> "zmodunbork:leggging"
-- }
local function patchClothingSelectionDefinitions()
    if not ClothingSelectionDefinitions or not ClothingSelectionDefinitions.default then return end

    for sex,def in pairs(ClothingSelectionDefinitions.default) do
        local keys = tableKeys(def)
        for _, key in ipairs(keys) do
            if _locations_registry[key:lower()] then
                def[_locations_registry[key:lower()]:toString()] = def[key]
                def[key] = nil
            end
        end
    end
end

local function patchItems(phase)
    local items = ScriptManager.instance:getAllItems()
    for i=0,items:size()-1 do
        local item = items:get(i)
        if item:getModID() ~= ScriptManager.VanillaID then
            checkItem(item, phase)
        end
    end
end

local function patchBodyLocationsAfterAll()
    logger:info("patchBodyLocationsAfterAll()")
    patchItems(2)
end

local function patchBodyLocationsBeforeAll()
    logger:info("patchBodyLocationsBeforeAll()")
    Events.OnGameBoot.Add(patchBodyLocationsAfterAll)
    patchItems(1)
    patchClothingSelectionDefinitions()
end

Events.OnGameBoot.Add(patchBodyLocationsBeforeAll)
