-- mods unborked:
--   DynamicTraits.2459400130

if not WeaponCategory then return end

local MAP = {
    -- ArrayList.get(i)
    [WeaponCategory.AXE]                   = "Axe",
    [WeaponCategory.BLUNT]                 = "Blunt",
    [WeaponCategory.IMPROVISED]            = "Improvised",
    [WeaponCategory.LONG_BLADE]            = "LongBlade",
    [WeaponCategory.SMALL_BLADE]           = "SmallBlade",
    [WeaponCategory.SMALL_BLUNT]           = "SmallBlunt",
    [WeaponCategory.SPEAR]                 = "Spear",
    [WeaponCategory.UNARMED]               = "Unarmed",

    -- Set.get(i)
    [tostring(WeaponCategory.AXE)]         = "Axe",
    [tostring(WeaponCategory.BLUNT)]       = "Blunt",
    [tostring(WeaponCategory.IMPROVISED)]  = "Improvised",
    [tostring(WeaponCategory.LONG_BLADE)]  = "LongBlade",
    [tostring(WeaponCategory.SMALL_BLADE)] = "SmallBlade",
    [tostring(WeaponCategory.SMALL_BLUNT)] = "SmallBlunt",
    [tostring(WeaponCategory.SPEAR)]       = "Spear",
    [tostring(WeaponCategory.UNARMED)]     = "Unarmed",
}

-- zombie/scripting/objects/Item.java
--   41.78: public ArrayList<String> getCategories()
--   42.12: public ArrayList<WeaponCategory> getWeaponCategories()
--   42.13: public Set<WeaponCategory> getWeaponCategories()
zdk.augment_metatable(Item.class, {
    getCategories = function(self)
        local result = ArrayList.new()
        if self.getWeaponCategories then
            local weaponCategories = self:getWeaponCategories()
            for i=0,weaponCategories:size()-1 do
                local cat = weaponCategories:get(i)
                local catStr = MAP[cat]
                if catStr then
                    result:add(catStr)
                end
            end
        end
        return result
    end
})

-- zombie/inventory/types/HandWeapon.java
--   41.78: public ArrayList<String> getCategories()
--   42.12: -
zdk.augment_metatable(HandWeapon.class, {
    getCategories = function(self)
        return self:getScriptItem():getCategories()
    end
})
