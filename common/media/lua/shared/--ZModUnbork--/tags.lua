local inv_item = instanceItem("Base.Belt2") -- zombie/inventory/InventoryItem.java
local item     = inv_item:getScriptItem()   -- zombie/scripting/objects/Item.java
local tags     = inv_item:getTags()         -- Set<ItemTag>

-- zombie/inventory/InventoryItem.java
-- zombie/scripting/objects/Item.java
--
-- 42.12    public ArrayList<String> getTags() - has get(index) method
-- 42.13.1  public Set<ItemTag>      getTags() - does not have get(index) method
--
-- patches metatable for Set<ItemTag>, so both InventoryItem.getTags and Item.getTags are affected
ZModUnbork.patch_metatable(tags, {
    get = function(self, index)
        local tag = self:toArray()[index+1] -- can be NULL if tag is not registered: [base:firearm, null, base:hasmetal]
        return tag and tag:toString() or ""
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

local function parse_tags(obj)
    local tags = {}

    local scriptLines
    if obj.getScriptLines then
        scriptLines = obj:getScriptLines()
    end

    if not scriptLines and obj.getScriptItem then
        local scriptItem = obj:getScriptItem()
        if scriptItem and scriptItem.getScriptLines then
            scriptLines = scriptItem:getScriptLines()
        end
    end

    if scriptLines then
        for i=0,scriptLines:size()-1 do
            local line = scriptLines:get(i):trim():gsub(" ", ""):lower()
            if line:startsWith("tags=") then
                local tagList = line:sub(6):split("[,;]")
                for _, tag in ipairs(tagList) do
                    tags[tag] = true
                end
            end
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
            print("[ZModUnbork] Item:hasTag(string) is no longer supported in 42.13+ - use Item:getTags():get(index) instead")
            print("[ZModUnbork] called with argument: " .. tagName)

            cachedTags = parse_tags(self)
            _cached_tags[fullType] = cachedTags
        end

        local result = cachedTags[tagName:lower()] or false
        if firstTime then
            print("[ZModUnbork] returning " .. tostring(result))
        end
        return result
    end

    return orig(self, ...)
end

for klassObj, mt in pairs(__classmetatables) do
    local index = mt.__index
    -- XXX have to use rawget() here to avoid calling any metamethods that regular tbl['hasTag'] or tbl.hasTag might potentially trigger
    -- random mods break in random places if "tbl['hasTag']" or "tbl.hasTag" is used here
    if type(index) == "table" and rawget(index, 'hasTag') then
        zbHook({
            [index] = {
                hasTag = patchedHasTag,
            },
        })
    end
end
