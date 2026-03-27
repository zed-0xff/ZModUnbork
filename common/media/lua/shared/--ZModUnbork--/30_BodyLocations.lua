-- unborked mods:
--   Furry
--   FortniteFurryGirls
--   newcontainers_B42.3535295548

if getCore():getGameVersion():isLessThan(GameVersion.parse("42.13")) then return end

local MOD_ID = "ZModUnbork"
local DEFAULT_PREFIX = MOD_ID

local logger = zdk.Logger.new(MOD_ID, zdk.Logger.DEBUG)
local _locations_registry = {}

ZModUnbork = ZModUnbork or {}
ZModUnbork.locations_registry = _locations_registry

local function get_call_origin()
    if not getCurrentCoroutine or not getCoroutineCallframeStack or not getFilenameOfCallframe or not getLineNumber then return end

    local ok, result = pcall(function()
        local coro = getCurrentCoroutine()
        if not coro then return end

        for i = 0,20 do
            local frame = getCoroutineCallframeStack(coro, i)
            if not frame then break end

            -- both getFilenameOfCallframe() and getLineNumber() could return nil
            local fname = getFilenameOfCallframe(frame)
            if fname and not fname:contains(MOD_ID) then
                local line = getLineNumber(frame)
                return { fname = fname, line = line }
            end
        end
    end)

    return ok and result or nil
end

local _logged_origins = {}
local function log_call_origin(origin)
    local line = origin.line and (":" .. tostring(origin.line)) or ""
    local origin_str = tostring(origin.fname) .. line
    if not _logged_origins[origin_str] then
        _logged_origins[origin_str] = true
        logger:info("    called from %s", origin_str)
    end
end

local _prefix_cache = {}
local function origin2prefix(origin)
    if not origin or not origin.fname then return DEFAULT_PREFIX end

    if _prefix_cache[origin.fname] then
        return _prefix_cache[origin.fname]
    end

    local prefix  = DEFAULT_PREFIX
    local modInfo = zdk.fname2mod(origin.fname)
    if modInfo then
        prefix = modInfo:getId():gsub("\\", "") -- remove heading slash from pre-42.15 mod ids
    end

    _prefix_cache[origin.fname] = prefix
    return prefix
end

-- convert String id to ItemBodyLocation, register if not exists, and cache in _locations_registry for future use
local function convert_id(id, fmt, ...)
    local callOrigin = get_call_origin()

    local origKey = id
    local lowKey  = origKey:lower()
    if _locations_registry[lowKey] == nil then -- values are true/false
        local loc = ItemBodyLocation.get(ResourceLocation.of(id)) -- try standard locations first - Furry: bodyGroup:indexOf("Bandage")
        if not loc then
            local fullKey = origKey
            if not fullKey:contains(":") then
                -- local prefix = origin2prefix(callOrigin)
                local prefix = DEFAULT_PREFIX
                fullKey = prefix .. ":" .. fullKey
            end
            loc = ItemBodyLocation.get(ResourceLocation.of(fullKey)) or ItemBodyLocation.register(fullKey)
        end
        if fmt then
            local src = string.format(fmt, ...)
            logger:info("%s -> %s", src, loc)
        end
        _locations_registry[lowKey] = loc
    end

    log_call_origin(callOrigin)

    return _locations_registry[lowKey]
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
            if type(id1) == "string" then id1 = convert_id(id1, "BodyLocationGroup.setHideModel") end
            if type(id2) == "string" then id2 = convert_id(id2, "BodyLocationGroup.setHideModel") end
            return orig(self, id1, id2, ...)
        end,

        -- 42.12: public void setExclusive(String id1, String id2)
        -- 42.13: public void setExclusive(ItemBodyLocation id1, ItemBodyLocation id2)
        setExclusive = function(orig, self, id1, id2, ...)
            if type(id1) == "string" then id1 = convert_id(id1, "BodyLocationGroup.setExclusive") end
            if type(id2) == "string" then id2 = convert_id(id2, "BodyLocationGroup.setExclusive") end
            return orig(self, id1, id2, ...)
        end,
    },

    -- zombie/characters/WornItems/BodyLocation.java
    BodyLocation = {
        -- 42.12: public BodyLocation(BodyLocationGroup group, String id)
        -- 42.13: public BodyLocation(BodyLocationGroup group, ItemBodyLocation id)
        new = function(orig, group, id, ...)
            ZModUnbork.last_group = group -- used in FurryMod_fix.lua
            if type(id) == "string" then id = convert_id(id, "BodyLocation.new(%s, '%s')", tostring(group), id) end
            return orig(group, id, ...)
        end,
    },

    -- zombie/characters/SurvivorDesc.java
    [SurvivorDesc.class] = {
        -- 42.12: public void setWornItem(String str, InventoryItem inventoryItem)
        -- 42.13: public void setWornItem(ItemBodyLocation itemBodyLocation, InventoryItem item)
        setWornItem = function(orig, self, loc, item, ...)
            if type(loc) == "string" then loc = convert_id(loc, "SurvivorDesc.setWornItem('%s')", loc) end
            return orig(self, loc, item, ...)
        end,
    },
})

local function checkItem(item)
    if not item.getBodyLocation or not item.setBodyLocation then return end
    if item:getBodyLocation() then return end -- already fixed

    local scriptTbl = zdk.parse_item_script(item)
    if not scriptTbl or not scriptTbl.bodylocation then return end

    local newLoc = _locations_registry[scriptTbl.bodylocation] -- expect value be in lowercase already
    if newLoc then
        logger:info("set %-13s to %-35s for %s", "bodyLocation", newLoc, item:getFullName())
        item:setBodyLocation(newLoc)
    else
        logger:warn("unknown bodyLocation %-20s for %s", scriptTbl.bodylocation, item:getFullName())
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

local function patchItems()
    local items = ScriptManager.instance:getAllItems()
    for i=0,items:size()-1 do
        local item = items:get(i)
        if item:getModID() ~= ScriptManager.VanillaID then
            checkItem(item)
        end
    end
end

local function patchBodyLocationsAfterAll()
    logger:info("patchBodyLocationsAfterAll()")
    patchItems()
end

local function patchBodyLocationsBeforeAll()
    logger:info("patchBodyLocationsBeforeAll()")
    Events.OnGameBoot.Add(patchBodyLocationsAfterAll)
    patchItems()
    patchClothingSelectionDefinitions()
end

Events.OnGameBoot.Add(patchBodyLocationsBeforeAll)
