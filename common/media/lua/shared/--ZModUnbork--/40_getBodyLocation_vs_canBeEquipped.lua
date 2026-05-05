-- mods unborked:
--   JusBanditsSG.3479281883
--   Support Corps.3512993822

-- XXX should be run AFTER patch_itemtypes.lua !

-- zombie.characters.WornItems
--   public void setFromItemVisuals(ItemVisuals itemVisuals) {
--     42.12:
--       ...
--       if ((inventoryItemCreateItem instanceof Clothing) && !StringUtils.isNullOrWhitespace(inventoryItemCreateItem.getBodyLocation())) {
--           setItem(inventoryItemCreateItem.getBodyLocation(), inventoryItemCreateItem);
--       } else if (!StringUtils.isNullOrWhitespace(inventoryItemCreateItem.canBeEquipped())) {
--           setItem(inventoryItemCreateItem.canBeEquipped(), inventoryItemCreateItem);
--       }
--       ...
--
--
--     42.13:
--       ...
--       if (item instanceof Clothing) {
--           setItem(item.getBodyLocation(), item);
--       } else {
--           setItem(item.canBeEquipped(), item);               // setItem() throws NPE because item.canBeEquipped is NULL (but item.getBodyLocation is not)
--       }
--       ...

local logger = ZModUnbork.logger

-- sanity check
if not ItemType or not ItemType.CLOTHING then
    logger:warn("ItemType.CLOTHING not found, skipping patch")
    return
end

local function checkItem(item)
    local itemType = item.getItemType and item:getItemType()
    if itemType == ItemType.CLOTHING or itemType == ItemType.ALARM_CLOCK_CLOTHING then return end -- Clothing items are OK

    local bodyLoc = item.getBodyLocation and item:getBodyLocation()
    if not bodyLoc then return end                                  -- not equippable, skip

    if zdk.parse_item_script(item)["canbeequipped"] then return end -- already fixed, skip

    ZModUnbork.clog('BodyLocations', "set %-13s to %-35s for %s", "canBeEquipped", bodyLoc, item:getFullName())
    item:DoParam("canBeEquipped", tostring(bodyLoc))
end

local function patchBodyLocations()
    local items = ScriptManager.instance:getAllItems()
    for i=0,items:size()-1 do
        local item = items:get(i)
        if item:getModID() ~= ScriptManager.VanillaID then
            checkItem(item)
        end
    end
end

Events.OnGameBoot.Add(patchBodyLocations)
