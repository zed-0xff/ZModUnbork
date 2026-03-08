local function patch_metatable(obj, functbl)
    if not obj then return end

    local mt = getmetatable(obj)
    if not mt then return end

    local index = mt.__index
    if not index then return end

    for methodName, func in pairs(functbl) do
        if not index[methodName] then -- patch only if method is not already defined
            index[methodName] = func
        end
    end
end

local item = instanceItem("Base.Belt2")


-- Add alias for method: if obj has nameA, add nameB that calls nameA (and vice versa).
-- Only one of (name_a, name_b) should exist on obj; the other is patched in.
local function patch_method_alias(obj, name_a, name_b)
    if not obj or not name_a or not name_b then return end
    local patch = {}
    if obj[name_a] then
        patch[name_b] = obj[name_a]
    elseif obj[name_b] then
        patch[name_a] = obj[name_b]
    end
    if not table.isempty(patch) then patch_metatable(obj, patch) end
end

-- zombie/inventory/types/Clothing.java
--   42.13.2  public float getDirtyness() / setDirtyness(float)
--   42.14    public float getDirtiness() / setDirtiness(float)
patch_method_alias(item, "getDirtiness", "getDirtyness")
patch_method_alias(item, "setDirtiness", "setDirtyness")

-- class AlarmClockClothing extends Clothing
local clock = instanceItem("Base.WristWatch_Left_ClassicGold")
if clock then
    -- fixes ItemComparison mod errors when showing tooltip for watches
    patch_method_alias(clock, "getDirtiness", "getDirtyness")
    patch_method_alias(clock, "setDirtiness", "setDirtyness")
end

-- zombie/scripting/objects/Item.java
--   42.12    public ArrayList<String> getTags()
--   42.13.1  public Set<ItemTag>      getTags()
patch_metatable(item:getTags(), {
    get = function(self, index)
        return self:toArray()[index+1]:toString()
    end
})


-- zombie/scripting/objects/Item.java
--   42.12    public String   getTypeString()
--   42.13.1  public ItemType getItemType()        XXX NOT EQUAL TO getStringItemType() !
if ItemType then
    local ITEM_TYPE_TO_STRING = {
        [ItemType.ALARM_CLOCK]          = "AlarmClock",
        [ItemType.ALARM_CLOCK_CLOTHING] = "AlarmClockClothing",
        [ItemType.ANIMAL]               = "Animal",
        [ItemType.CLOTHING]             = "Clothing",
        [ItemType.CONTAINER]            = "Container",
        [ItemType.DRAINABLE]            = "Drainable",
        [ItemType.FOOD]                 = "Food",
        [ItemType.KEY]                  = "Key",
        [ItemType.KEY_RING]             = "KeyRing",
        [ItemType.LITERATURE]           = "Literature",
        [ItemType.MAP]                  = "Map",
        [ItemType.MOVEABLE]             = "Moveable",
        [ItemType.NORMAL]               = "Normal",
        [ItemType.RADIO]                = "Radio",
        [ItemType.WEAPON]               = "Weapon",
        [ItemType.WEAPON_PART]          = "WeaponPart",
    }

    patch_metatable(item:getScriptItem(), {
        getTypeString = function(self)
            if not self.getItemType then return nil end
            local itemType = self:getItemType()
            return ITEM_TYPE_TO_STRING[itemType]
        end
    })
end
