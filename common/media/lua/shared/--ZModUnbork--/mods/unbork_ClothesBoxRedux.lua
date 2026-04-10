-- mods fixed:
--   ClothesBoxRedux.2847911733

-- two problems in the original mod code:
--   1. boxclothBodyLocations.lua defines setupAuthenticZBodyLocations(), but calls Events.OnGameBoot.Add(addCustomBodyLocations)
--   2. "CanBeEquipped = 999" item script lines are ignored because they don't have the 'CBX:' prefix

local MOD_ID = "ClothesBoxRedux"
if not getActivatedMods():contains(MOD_ID) then return end

local logger = ZModUnbork.logger

-- CBX_BodyLocations.lua
-- Build 42.13+ Multiplayer-safe body location setup for AuthenticZ
-- Uses deterministic rebuild + anchored insertion

require "NPCs/BodyLocations"

local BodyAPI = BodyLocations
local SlotAPI = ItemBodyLocation
local RL = ResourceLocation

------------------------------------------------------------
-- Utility: clone layering rules from an existing group
------------------------------------------------------------
local function cloneLocationRules(sourceGroup, locationId, targetGroup)
    for i = 0, sourceGroup:size() - 1 do
        local otherId = sourceGroup:getLocationByIndex(i):getId()

        if sourceGroup:isExclusive(locationId, otherId) then
            targetGroup:setExclusive(locationId, otherId)
        end
        if sourceGroup:isHideModel(locationId, otherId) then
            targetGroup:setHideModel(locationId, otherId)
        end
        if sourceGroup:isAltModel(locationId, otherId) then
            targetGroup:setAltModel(locationId, otherId)
        end
    end
end

------------------------------------------------------------
-- Core: rebuild a body group and inject new locations
------------------------------------------------------------
local function rebuildGroupWithInsertions(targetGroupId, insertions)
    local created = {}

    -- Snapshot groups (reset clears the live view)
    local groupView = BodyAPI.getAllGroups()
    local groupSnapshot = {}
    for i = 0, groupView:size() - 1 do
        groupSnapshot[#groupSnapshot + 1] = groupView:get(i)
    end

    BodyAPI.reset()

    for _, oldGroup in ipairs(groupSnapshot) do
        local newGroup = BodyAPI.getGroup(oldGroup:getId())

        for i = 0, oldGroup:size() - 1 do
            local existingId = oldGroup:getLocationByIndex(i):getId()

            -- Insert BEFORE anchor
            if oldGroup:getId() == targetGroupId then
                for _, def in ipairs(insertions) do
                    if def.before then
                        local anchorId = type(def.anchor) == "string"
                            and RL.of(def.anchor)
                            or def.anchor

                        if anchorId == existingId then
                            local newId = type(def.id) == "string"
                                and SlotAPI.get(RL.of(def.id))
                                or def.id

                            created[def.id] = newGroup:getOrCreateLocation(newId)
                        end
                    end
                end
            end

            -- Recreate original vanilla slot
            newGroup:getOrCreateLocation(existingId)

            -- Insert AFTER anchor
            if oldGroup:getId() == targetGroupId then
                for _, def in ipairs(insertions) do
                    if not def.before then
                        local anchorId = type(def.anchor) == "string"
                            and RL.of(def.anchor)
                            or def.anchor

                        if anchorId == existingId then
                            local newId = type(def.id) == "string"
                                and SlotAPI.get(RL.of(def.id))
                                or def.id

                            created[def.id] = newGroup:getOrCreateLocation(newId)
                        end
                    end
                end
            end
        end

        -- Restore vanilla behavior
        for i = 0, oldGroup:size() - 1 do
            local locId = oldGroup:getLocationByIndex(i):getId()
            newGroup:setMultiItem(locId, oldGroup:isMultiItem(locId))
            cloneLocationRules(oldGroup, locId, newGroup)
        end
    end

    return created
end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------
local function setupAuthenticZBodyLocations()
    -- Fallback for older/newer branches
    local outerVestLayer = SlotAPI.TorsoExtraVestBullet
    if not outerVestLayer then
        outerVestLayer = SlotAPI.TorsoExtraVest
    end

    rebuildGroupWithInsertions("Human", {
        -- Head accessories (stackable with hats)
        { id = "CBX:101", anchor = SlotAPI.HAT },
        { id = "CBX:010", anchor = SlotAPI.HAT },
        { id = "CBX:999", anchor = SlotAPI.HAT },
        -- Neck accessories (remain visible over jackets)
        { id = "CBX:888", anchor = SlotAPI.JACKET },
        -- Shin gear (over pants, under shoes)
        { id = "CBX:898", anchor = SlotAPI.SHOES, before = true },
    })
end

local function checkItem(item)
    local scriptTbl = zdk.parse_item_script(item)
    if not scriptTbl or not scriptTbl.canbeequipped then return end

    -- check if scriptTbl.canbeequipped is 3-digit string
    if scriptTbl.canbeequipped:match("^%d%d%d$") then
        logger:info("set CanBeEquipped to CBX:%s for %s", scriptTbl.canbeequipped, item:getFullName())
        item:DoParam("CanBeEquipped", "CBX:" .. scriptTbl.canbeequipped)
    end
end

local function fix_ClothesBoxRedux()
    logger:info("fixing %s mod", MOD_ID)

    setupAuthenticZBodyLocations()

    local items = ScriptManager.instance:getAllItems()
    for i=0,items:size()-1 do
        local item = items:get(i)
        if item:getModID() == MOD_ID then
            checkItem(item)
        end
    end
end

local function checkClothesBoxRedux2()
    local cbx999 = ItemBodyLocation.get(ResourceLocation.of("cbx:999"))
    if not cbx999 then
        -- name changed?
        return
    end
    if BodyLocations.getGroup("Human"):getLocation(cbx999) then
        -- all good
        return
    end

    fix_ClothesBoxRedux()
end

-- run after all other OnGameBoot events
local function checkClothesBoxRedux1()
    Events.OnGameBoot.Add(checkClothesBoxRedux2)
end

Events.OnGameBoot.Add(checkClothesBoxRedux1)
