-- mods unborked:
--   RealisticClothes.3491510356

if Type then return end

Type = {
    AlarmClock         = ItemType.ALARM_CLOCK,
    AlarmClockClothing = ItemType.ALARM_CLOCK_CLOTHING,
    Animal             = ItemType.ANIMAL,
    Clothing           = ItemType.CLOTHING,
    Container          = ItemType.CONTAINER,
    Drainable          = ItemType.DRAINABLE,
    Food               = ItemType.FOOD,
    Key                = ItemType.KEY,
    KeyRing            = ItemType.KEY_RING,
    Literature         = ItemType.LITERATURE,
    Map                = ItemType.MAP,
    Moveable           = ItemType.MOVEABLE,
    Normal             = ItemType.NORMAL,
    Radio              = ItemType.RADIO,
    Weapon             = ItemType.WEAPON,
    WeaponPart         = ItemType.WEAPON_PART,
}

zdk.augment_metatable( Item.class, {
    getType = "getItemType",
})
