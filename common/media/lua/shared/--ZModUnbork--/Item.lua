if not ItemType then return end

local item = instanceItem("Base.Belt2")

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
ZModUnbork.patch_metatable(item:getScriptItem(), {
    getTypeString = function(self)
        if not self.getItemType then return nil end
        local itemType = self:getItemType()
        return ITEM_TYPE_TO_STRING[itemType]
    end
})
