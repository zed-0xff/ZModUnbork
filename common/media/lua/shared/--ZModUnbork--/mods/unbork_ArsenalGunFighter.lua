-- mods unborked:
--   ArsenalGunFighter.2297098490 (B41)

local ARSENAL_MOD_ID = "Arsenal(26)GunFighter[MAIN MOD 2.0]"
if not getActivatedMods():contains(ARSENAL_MOD_ID) then return end

-- 42.12: public String   Item.getAmmoType()
-- 42.13: public AmmoType Item.getAmmoType()
zdk.patch_all_metatables("getAmmoType", {
    getAmmoType = function(orig, self, ...)
        local result = orig(self, ...)

        if instanceof(result, "AmmoType") and zdk.get_call_origin_mod_id(ZModUnbork.MOD_ID) == ARSENAL_MOD_ID and result.getItemKey then
            local strValue = result:getItemKey()
            ZModUnbork.clog_once('AmmoType', "converting AmmoType %s to string %S", result, strValue)
            return strValue
        end

        return result
    end
})

local function patched_getItemCount(orig, self, itemType, ...)
    if instanceof(itemType, "AmmoType") and itemType.getItemKey then
        local strValue = itemType:getItemKey()
        ZModUnbork.clog_once('AmmoType', "converting AmmoType %s to string %S", itemType, strValue)
        itemType = strValue
    end
    return orig(self, itemType, ...)
end

zdk.hook({
    [ItemContainer.class] = {
        -- 	java.lang.RuntimeException: No implementation found for function: <func>( ItemContainer, AmmoType, ... )
        getItemCount        = patched_getItemCount,
        getItemCountRecurse = patched_getItemCount,
        getSomeType         = patched_getItemCount,
        getSomeTypeRecurse  = patched_getItemCount,
    }
})

-- 42.15: public String           HandWeapon.getWeaponReloadType()
-- 42.16: public WeaponReloadType HandWeapon.getWeaponReloadType()
zdk.patch_all_metatables("getWeaponReloadType", {
    getWeaponReloadType = function(orig, self, ...)
        local result = orig(self, ...)

        if instanceof(result, "WeaponReloadType") and zdk.get_call_origin_mod_id(ZModUnbork.MOD_ID) == ARSENAL_MOD_ID then
            local strValue = result:toString()
            ZModUnbork.clog_once('WeaponReloadType', "converting WeaponReloadType %s to string %S", result, strValue)
            return strValue
        end

        return result
    end
})

-- 	java.lang.RuntimeException: No implementation found for function: setAnimVariable( LuaTimedActionNew, WeaponReloadType, WeaponReloadType )
zdk.patch_all_metatables("setAnimVariable", {
    setAnimVariable = function(orig, self, key, val, ...)
        if instanceof(key, "WeaponReloadType") then
            local strValue = key:toString()
            ZModUnbork.clog_once('WeaponReloadType', "converting WeaponReloadType %s to string %S", key, strValue)
            key = strValue
        end
        if instanceof(val, "WeaponReloadType") then
            local strValue = val:toString()
            ZModUnbork.clog_once('WeaponReloadType', "converting WeaponReloadType %s to string %S", val, strValue)
            val = strValue
        end

        return orig(self, key, val, ...)
    end
})
