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

            local mod_id = zdk.get_call_origin_mod_id(ZModUnbork.MOD_ID)
            if mod_id == "DynamicTraits" or mod_id == "Bandits2" then
                ZModUnbork.clog_once('fix_bandits_moodle', "IsoZombie.getMoodles()")
                return { getMoodleLevel = function() return 0 end }
            end

            return result
        end
    }
})
