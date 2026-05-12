-- mods unborked:
--   ArsenalGunFighter.2297098490 (B41)
--   (lots of mods using string tags)

-- zombie/inventory/InventoryItem.java
-- zombie/scripting/objects/Item.java
--
-- 42.12: public ArrayList<String> getTags() - has get(index) method
-- 42.13: public Set<ItemTag>      getTags() - does not have get(index) method
--
-- patches metatable for Set<ItemTag>, so both InventoryItem.getTags and Item.getTags are affected
zdk.augment_metatable(HashSet.class, {
    get = function(self, index)
        local obj = self:toArray()[index+1] -- can be NULL if obj is not registered: [base:firearm, null, base:hasmetal]
        if instanceof(obj, "ItemTag") then
            ZModUnbork.clog_once('getTags:get', 'getTags:get')
            return obj and obj:toString() or ""
        else
            -- 42.17: getCell():getVehicles() returns a Set<BaseVehicle> which also lands here
            return obj
        end
    end
})

local function patchedHasTag(orig, self, ...)
    local nArgs = select("#", ...)
    local tagName = select(1, ...)
    if nArgs == 1 and type(tagName) == "string" then
        local tag = ZModUnbork.RegCache.find( Registries.ITEM_TAG, tag )
        ZModUnbork.clog_once('hasTag', "%s:hasTag(%S) => %s", self, tagName, tag)
        return tag and orig(self, tag)
    end

    return orig(self, ...)
end

-- 42.12
--    public boolean hasTag(ItemTag itemTag) {
--    public boolean hasTag(String str) {
--
-- 42.13
--    public boolean hasTag(ItemTag itemTag) {
--    public boolean hasTag(ItemTag... tags) {
zdk.patch_all_metatables('hasTag', {
    hasTag = patchedHasTag
})

-- 42.12: public boolean IsoGameCharacter.hasEquippedTag(String str)
-- 42.13: public boolean IsoGameCharacter.hasEquippedTag(ItemTag itemTag)
zdk.patch_all_metatables('hasEquippedTag', {
    hasEquippedTag = function(orig, self, tag, ...)
        if not tag then
            ZModUnbork.warn_once("hasEquippedTag called with nil tag")
            return false
        end
        if type(tag) == "string" then
            ZModUnbork.clog_once('hasEquippedTag', "hasEquippedTag(%S)", tag)
            local hands = { 'getPrimaryHandItem', 'getSecondaryHandItem' }
            for _, hand in ipairs(hands) do
                local item = self[hand] and self[hand](self)
                if item and item:hasTag(tag) then
                    return true
                end
            end
            return false
        end

        return orig(self, tag, ...)
    end
})

-- 42.12: public ArrayList<Item> ScriptManager.getItemsTag(String str)
-- 42.13: public ArrayList<Item> ScriptManager.getItemsTag(ItemTag itemTag)
zdk.hook({
    [ScriptManager.class] = {
        getItemsTag = function(orig, self, tag, ...)
            if not tag then
                ZModUnbork.warn_once("getItemsTag called with nil tag")
                return false
            end
            if type(tag) == "string" then
                ZModUnbork.clog_once('getItemsTag', "getItemsTag(%S)", tag) 
                tag = ZModUnbork.RegCache.find( Registries.ITEM_TAG, tag )
                if not tag then return false end
            end
            return orig(self, tag, ...)
        end
    }
})
