-- mods unborked:
--   RC_RealisticColdMod.3600401184

if not getActivatedMods():contains("RC_RealisticColdMod") then return end

-- mod's snapshotBodyPartWetness() function gathers wetness from body parts (BodyPartType), and then tries to update it from clothing's BloodBodyPartType
-- but BloodBodyPartType.Back exists, and BodyPartType.Back does not, so it throws
--   java.lang.RuntimeException: __add not defined for operands in _applyBodyWetnessDeltaToClothing at KahluaUtil.fail(KahluaUtil.java:99).
--     in _applyBodyWetnessDeltaToClothing(SimulationWetness.lua:184)

local _wetnessCoveredParts = ArrayList and ArrayList.new()

---@param item any
---@return any
local function _getClothingWetnessCoveredParts(item)
    if not item or not item.getModData then
        return nil
    end
    if not BloodBodyPartType or not BloodBodyPartType.MAX then
        return nil
    end

    local modData = item:getModData()
    if not modData then
        return nil
    end

    local cached = modData.rcWetCoveredParts
    if cached ~= nil then
        return cached
    end

    cached = false
    if item.getBloodClothingType and BloodClothingType and BloodClothingType.getCoveredParts and _wetnessCoveredParts then
        local bloodTypes = item:getBloodClothingType()
        if bloodTypes then
            local covered = BloodClothingType.getCoveredParts(bloodTypes, _wetnessCoveredParts)
            if covered and covered.size and covered:size() > 0 then
                local list = {}
                for i = 0, covered:size() - 1 do
                    local part = covered:get(i)
                    local index = part and part:index()
                    if index and index >= 0 then
                        list[#list + 1] = index
                    end
                end
                if #list > 0 then
                    cached = list
                end
            end
        end
    end

    modData.rcWetCoveredParts = cached
    return cached
end

local function fixSnapshot(snapshot, body)
    local player = body.getParentChar and body:getParentChar()
    if not player then return end

    local maxParts = BloodBodyPartType.MAX:index()
    if not maxParts or maxParts <= 0 then
        return
    end

    local worn = player:getWornItems()
    if not worn or not worn.size or worn:size() <= 0 then
        return
    end

    for i = 0, worn:size() - 1 do
        local clothing = worn:getItemByIndex(i)
        if clothing and clothing.getWetness and clothing.setWetness then
            local covered = _getClothingWetnessCoveredParts(clothing)
            if covered and covered ~= false and #covered > 0 then
                for j = 1, #covered do
                    local partIndex = covered[j]
                    if partIndex and partIndex >= 0 and partIndex < maxParts then
                        if not snapshot[partIndex] then
                            ZModUnbork.log_once("snapshotBodyPartWetness: setting snapshot[%d] to %f from %s", partIndex, clothing:getWetness(), clothing)
                            snapshot[partIndex] = clothing:getWetness()
                        end
                    end
                end
            end
        end
    end
end

local HOOKED_REQUIRE = "RC_TempSim/body/SimulationWetness"

zdk.hook({
    _G = {
        require = function(orig, moduleName, ...)
            local result = orig(moduleName, ...)
            if moduleName == HOOKED_REQUIRE then
                local hook_res = zdk.hook({
                    [result] = {
                        snapshotBodyPartWetness = function(orig2, body2, ...)
                            local result2 = orig2(body2, ...)
                            fixSnapshot(result2, body2)
                            return result2
                        end
                    }
                })
                ZModUnbork.logger:info("%s hook result: %s", HOOKED_REQUIRE, hook_res)
            end
            return result
        end
    }
})
