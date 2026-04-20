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


-- 42.12
--    public boolean hasTag(ItemTag itemTag) {
--    public boolean hasTag(String str) {
--
-- 42.13
--    public boolean hasTag(ItemTag itemTag) {
--    public boolean hasTag(ItemTag... tags) {

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
    local args = {...}
    if #args == 1 and type(args[1]) == "string" then
        local tagName = args[1]

        local fullType = (self.getFullType and self:getFullType()) or (self.getFullName and self:getFullName())
        if not fullType then
            print("[ZModUnbork] ERROR: could not determine full type for", self)
            return false
        end

        local cachedTags = _cached_tags[fullType]
        local firstTime = not cachedTags
        if firstTime then
            cachedTags = parse_tags(self)
            _cached_tags[fullType] = cachedTags
        end

        local result = cachedTags[tagName:lower()] or false
        if firstTime then
            print(string.format("[ZModUnbork] %s:hasTag('%s') => %s", tostring(fullType), tagName, tostring(result)))
        end
        return result
    end

    return orig(self, ...)
end

zdk.patch_all_metatables('hasTag', {
    hasTag = patchedHasTag
})
