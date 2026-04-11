-- mods unborked:
--   - DynamicTraits.2459400130

if not getActivatedMods():contains("Bandits2") then return end
if not getActivatedMods():contains("DynamicTraits") then return end

-- it listens on Events.OnWeaponHitCharacter, and gets notification that a zombie has been hit,
-- it falsely assumes that it has been hit by a player, but it actually was hit by a Bandit,
-- which is an instance of IsoZombie class, which returns nil from getMoodles()
zdk.hook({
    [IsoZombie.class] = {
        getMoodles = function(orig, ...)
            local result = orig(...)
            if result then return result end

            local origin = zdk.get_call_origin(ZModUnbork.MOD_ID)
            if origin and origin.mod and origin.mod.getId then
                local id = origin.mod:getId()
                if id == "DynamicTraits" or id == "Bandits2" then
                    ZModUnbork.log_once("IsoZombie.getMoodles()")
                    return { getMoodleLevel = function() return 0 end }
                end
            end

            return result
        end
    }
})
