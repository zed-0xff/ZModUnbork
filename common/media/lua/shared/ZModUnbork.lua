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

-- zombie/inventory/types/Clothing.java
--   42.12    public float getDirtyness()
--   42.13.1  public float getDirtiness()
--   42.13.2  public float getDirtyness()
--   42.14    public float getDirtiness()
local function patch_clothing_dirtiness(obj)
    if not obj then return end
    local patch = {}
    if obj.getDirtiness then
        patch.getDirtyness = function(self) return self:getDirtiness() end
    elseif obj.getDirtyness then
        patch.getDirtiness = function(self) return self:getDirtyness() end
    end
    if next(patch) then patch_metatable(obj, patch) end
end
patch_clothing_dirtiness(item)

-- zombie/scripting/objects/Item.java
--   42.12    public ArrayList<String> getTags()
--   42.13.1  public Set<ItemTag>      getTags()
patch_metatable(item:getTags(), {
    get = function(self, index)
        return self:toArray()[index+1]
    end
})

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

    -- zombie/scripting/objects/Item.java
    --   42.12    public String   getTypeString()
    --   42.13.1  public ItemType getItemType()        XXX NOT EQUAL TO getStringItemType() !
    patch_metatable(item:getScriptItem(), {
        getTypeString = function(self)
            if not self.getItemType then return nil end
            local itemType = self:getItemType()
            return ITEM_TYPE_TO_STRING[itemType]
        end
    })
end
