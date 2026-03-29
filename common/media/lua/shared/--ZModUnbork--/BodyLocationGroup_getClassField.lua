-- mods unborked:
--   Furry.2893930681
--   SomeTattoo.3318917504
--   SomeScar.3315365342
--   Spongie Clothing.2684285534
--   SpongieOpenJackets.2812326159

-- reflection methods work in debug mode only since 42.15
if getCore():getGameVersion():isLessThan(GameVersion.parse("42.15")) then return end

local logger = zdk.Logger.new("ZModUnbork")

local _lastLocs   = nil
local _lastRemove = nil

local group = BodyLocations.getGroup("Human") -- despite the name here it will patch all body locations, not just human ones
zdk.hook({
    -- 42.13+ returns Collections.unmodifiableList, and FurryMod tries to call add() and remove() on it
    -- List<BodyLocation>
    [group:getAllLocations()] = {
        add = function(orig, self, index, locationObj, ...)
            if type(index) == "number" then
                -- add(index, obj)
                if _lastLocs and _lastLocs == self and _lastRemove and _lastRemove == locationObj and ZModUnbork.last_group and ZModUnbork.last_group.moveLocationToIndex then
                    _lastRemove = nil
                    local id = nil
                    if instanceof(locationObj, "BodyLocation") then
                        id = locationObj:getId()
                    elseif instanceof(locationObj, "ItemBodyLocation") then
                        id = locationObj
                    else
                        logger:error("BodyLocationGroup.list.add(%d, %s) called with unexpected argument type %s", index, locationObj, type(locationObj))
                        return
                    end
                    logger:info("BodyLocationGroup.list.add(%d, %s) => group:moveLocationToIndex(%s, %d)", index, locationObj, id, index)
                    ZModUnbork.last_group:moveLocationToIndex(id, index) -- expects ItemBodyLocation, int
                else
                    logger:info("BodyLocationGroup.list.add(%d, %s) called on unmodifiable list, ignored", index, locationObj)
                end
            elseif not locationObj then
                -- add(obj)
                locationObj = index
                local id = nil
                if instanceof(locationObj, "BodyLocation") then
                    id = locationObj:getId()
                elseif instanceof(locationObj, "ItemBodyLocation") then
                    id = locationObj
                else
                    logger:error("BodyLocationGroup.list.add(%s) called with unexpected argument type %s", locationObj, type(locationObj))
                    return
                end
                logger:info("BodyLocationGroup.list.add(%s) => group:getOrCreateLocation(%s)", locationObj, id)
                ZModUnbork.last_group:getOrCreateLocation(id) -- expects ItemBodyLocation
            else
                -- ??
                logger:error("BodyLocationGroup.list.add(%s, %s) called with unexpected arguments, ignored", index, locationObj)
            end
        end,

        remove = function(orig, self, locationObj, ...)
            _lastRemove = locationObj
            logger:info("BodyLocationGroup.list.remove(%s) called on unmodifiable list, ignored", locationObj)
        end,
    },
})

-- getClassField/getClassFieldVal works in debug mode only since 42.15
if isDebugEnabled() then return end

zdk.hook({
    _G = {
        getClassField = function(orig, obj, fieldIdx, ...)
            ZModUnbork.log_once("getClassField(%s, %s)", getClassSimpleName(obj), fieldIdx)
            local result = nil

            if instanceof(obj, "BodyLocationGroup") then
                if fieldIdx == 1 then -- private final List<BodyLocation> locations
                    result = "BodyLocationGroup_locations"
                end
            elseif instanceof(obj, "BodyLocation") then
                if fieldIdx == 2 then -- List<ItemBodyLocation> exclusive
                    result = "BodyLocation_exclusive"
                end
                if fieldIdx == 3 then -- List<ItemBodyLocation> hideModel
                    result = "BodyLocation_hideModel"
                end
            end

            return result or orig(obj, fieldIdx, ...)
        end,

        getClassFieldVal = function(orig, obj, fieldObj, ...)
            ZModUnbork.log_once("getClassFieldVal(%s, %s)", getClassSimpleName(obj), fieldObj)
            local result = nil

            if instanceof(obj, "BodyLocationGroup") then
                if fieldObj == "BodyLocationGroup_locations" then
                    ZModUnbork.last_group = obj
                    _lastLocs = obj:getAllLocations()
                    result = _lastLocs
                end
            elseif instanceof(obj, "BodyLocation") then
                if fieldObj == "BodyLocation_exclusive" then
                    -- SpongieCopy_BodyLocationsTweaker.lua:24 - there is no way to modify it now, so returning a stub
                    result = { remove = function() end }
                end
                if fieldObj == "BodyLocation_hideModel" then
                    -- SpongieCopy_BodyLocationsTweaker.lua:36 - there is no way to modify it now, so returning a stub
                    result = { remove = function() end }
                end
            end

            return result or orig(obj, fieldObj, ...)
        end,
    },
})
