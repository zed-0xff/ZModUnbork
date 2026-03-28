-- mods unborked:
--   Furry.2893930681
--   FurryApocalypseAnthroAccessories.3238978135
--   newcontainers_B42.3535295548
--   Support Corps.3512993822
--   Support Goods - MyComputers.3508513470
--   PFO_GUNRUNNER.3434691822

local logger = ZModUnbork.logger

if not ItemType or not ItemType.NORMAL then
    logger:warn("ItemType not found, skipping patch_itemtypes")
    return
end

local function checkItem(item)
    if not item.getItemType or not item.setItemType then return end

    local curType = item:getItemType()
    if curType and curType ~= ItemType.NORMAL then return end -- already fixed

    local scriptTbl = zdk.parse_item_script(item)
    if not scriptTbl or not scriptTbl.type then return end

    local newType = ItemType.get(ResourceLocation.of(scriptTbl.type))
    if newType then
        if newType ~= curType then
            logger:info("set %-13s to %-35s for %s", "itemType", newType, item:getFullName())
            item:setItemType(newType)

            if newType == ItemType.WEAPON and scriptTbl.ammotype and item.getAmmoType and not item:getAmmoType() then
                local ammoType = ZModUnbork.RegCache.convert_id(Registries.AMMO_TYPE, scriptTbl.ammotype, scriptTbl.ammotype)
                if ammoType then
                    item:setAmmoType(ammoType)
                    logger:info("set %-13s to %-35s for %s", "ammoType", ammoType, item:getFullName())
                else
                    logger:warn("invalid ammoType %-20s for %s", scriptTbl.ammotype, item:getFullName())
                end
            end
        end
    else
        logger:warn("unknown itemType %-20s for %s", scriptTbl.type, item:getFullName())
    end
end

local function patchItemTypes()
    local items = ScriptManager.instance:getAllItems()
    for i=0,items:size()-1 do
        local item = items:get(i)
        if item:getModID() ~= ScriptManager.VanillaID then
            checkItem(item)
        end
    end
end

Events.OnGameBoot.Add(patchItemTypes)
