-- mods unborked:
--   ArsenalGunFighter.2297098490 (B41)
--   (lots of mods using string tags)

-- zombie/inventory/InventoryItem.java
-- zombie/scripting/objects/Item.java
--
-- 42.12    public ArrayList<String> getTags() - has get(index) method
-- 42.13.1  public Set<ItemTag>      getTags() - does not have get(index) method
--
-- patches metatable for Set<ItemTag>, so both InventoryItem.getTags and Item.getTags are affected
zdk.augment_metatable(HashSet.class, {
    get = function(self, index)
        local obj = self:toArray()[index+1] -- can be NULL if obj is not registered: [base:firearm, null, base:hasmetal]
        if instanceof(obj, "ItemTag") then
            return obj and obj:toString() or ""
        else
            -- 42.17: getCell():getVehicles() returns a Set<BaseVehicle> which also lands here
            return obj
        end
    end
})

local _cached_tags = {}

local function parse_tags(item)
    local scriptTbl = zdk.parse_item_script(item)
    local tags = {}

    if scriptTbl and scriptTbl.tags then
        local tagList = scriptTbl.tags:lower():split(";")
        for _, tag in ipairs(tagList) do
            tags[tag] = true
        end
    end

    return tags
end

local function patchedHasTag(orig, self, ...)
    local nArgs = select("#", ...)
    local tagName = select(1, ...)
    if nArgs == 1 and type(tagName) == "string" then
        local fullType = (self.getFullType and self:getFullType()) or (self.getFullName and self:getFullName())
        if not fullType then
            ZModUnbork.warn_once("could not determine full type for %s", self)
            return false
        end

        local cachedTags = _cached_tags[fullType]
        if not cachedTags then
            cachedTags = parse_tags(self)
            _cached_tags[fullType] = cachedTags
        end

        local result = cachedTags[tagName:lower()] or false
        ZModUnbork.clog_once('tags', "%s:hasTag(%S) => %s", fullType, tagName, result)
        return result
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
    hasEquippedTag = function(orig, self, tagName, ...)
        if type(tagName) == "string" then
            local hands = { 'getPrimaryHandItem', 'getSecondaryHandItem' }
            for _, hand in ipairs(hands) do
                local item = self[hand] and self[hand](self)
                if item and item:hasTag(tagName) then
                    return true
                end
            end
            return false
        end

        return orig(self, tagName, ...)
    end
})
