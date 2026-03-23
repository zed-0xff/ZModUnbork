-- unborked mods:
--   Furry              - Anthro Survivors (the "Furry Mod")
--   FortniteFurryGirls - Furry Apocalypse Anthro Survivors - Fortnite Furry Girls (b42 conversion)

if getCore():getGameVersion():isLessThan(GameVersion.parse("42.13")) then return end

local _locations_registry = {}

-- convert String id to ItemBodyLocation, register if not exists, and cache in _locations_registry for future use
local function convert_id(id, fmt, ...)
    local origKey = id
    local lowKey  = origKey:lower()
    if not _locations_registry[lowKey] then
        local loc = ItemBodyLocation.get(ResourceLocation.of(id)) -- try standard locations first - Furry: bodyGroup:indexOf("Bandage")
        if not loc then
            local fullKey = origKey
            if not fullKey:contains(":") then
                fullKey = "ZModUnbork:" .. fullKey -- can we get original mod id somehow without java patching?
            end
            loc = ItemBodyLocation.get(ResourceLocation.of(fullKey)) or ItemBodyLocation.register(fullKey)
        end
        if fmt then
            local src = string.format(fmt, ...)
            print(string.format("[ZModUnbork] %s -> %s", src, tostring(loc)))
        end
        _locations_registry[lowKey] = loc
    end
    return _locations_registry[lowKey]
end

local group = BodyLocations.getGroup("Human") -- despite the name here it will patch all body locations, not just human ones
zdk.hook({
    -- zombie/characters/WornItems/BodyLocationGroup.java
    [group] = {
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
})

local function checkItem(item)
    if not item.getBodyLocation or not item.setBodyLocation then return end
    if item:getBodyLocation() then return end -- already fixed

    local scriptTbl = zdk.parse_item_script(item)
    if not scriptTbl or not scriptTbl.bodylocation then return end

    local newLoc = _locations_registry[scriptTbl.bodylocation] -- expect value be in lowercase already
    if newLoc then
        print(string.format("[ZModUnbork] set bodyLocation to %-35s for %s", tostring(newLoc), item:getFullName()))
        item:setBodyLocation(newLoc)
    end
end

local function patchBodyLocations()
    local items = ScriptManager.instance:getAllItems()
    for i=0,items:size()-1 do
        local item = items:get(i)
        if item:getModID() ~= ScriptManager.VanillaID then
            checkItem(item)
        end
    end
end

Events.OnInitWorld.Add(patchBodyLocations)
