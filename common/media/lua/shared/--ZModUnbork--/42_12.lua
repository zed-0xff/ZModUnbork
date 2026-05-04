-- mods unborked:
--   ArsenalGunFighter.2297098490 (B41)

InventoryItemFactory = InventoryItemFactory or {}
if not InventoryItemFactory.CreateItem then
    function InventoryItemFactory.CreateItem(x)
        if type(x) == "string" then
            return instanceItem(x)
        elseif instanceof(x, "AmmoType") and x.getItemKey and x:getItemKey() then
            return instanceItem(x:getItemKey())
        else
            ZModUnbork.warn_once("InventoryItemFactory.CreateItem: unexpected argument %s, type=%s", x, type(x))
            return nil
        end
    end
end

zdk.augment_metatable( IsoPlayer.class, {
    startMuzzleFlash = function() end, -- TODO: proper flash
})

-- 41.78: public static float GameTime.getAnimSpeedFix() { return 0.8f; }
-- 42.12: -
GameTime = GameTime or {}
if not GameTime.getAnimSpeedFix then
    GameTime.getAnimSpeedFix = function() return 0.8 end
end

local function patchReloadWeaponAction_afterAll()
    -- 41.78: function ISReloadWeaponAction.canShoot(weapon)
    -- 42.12: function ISReloadWeaponAction.canShoot(player, weapon)
    if getFilenameOfClosure(ISReloadWeaponAction.canShoot):contains('/ARSENAL(26)GunFighter[MOD 2.0]/media/lua/client/TimedActions/ISReloadWeaponAction.lua') then
        -- map 2 arg -> 1 arg
        zdk.hook({
            ISReloadWeaponAction = {
                canShoot = function(orig, x, y)
                    local weapon = nil
                    if x and y then
                        weapon = y
                    elseif x and not y then
                        weapon = x
                    end
                    return weapon and orig(weapon)
                end
            }
        })
    else
        -- map 1 arg -> 2 arg
        zdk.hook({
            ISReloadWeaponAction = {
                canShoot = function(orig, x, y)
                    local player = nil
                    local weapon = nil
                    if x and y then
                        player, weapon = x, y
                    elseif x and not y then
                        weapon = x
                        player = weapon.getPlayer and weapon:getPlayer()
                    end
                    return player and weapon and orig(player, weapon)
                end
            }
        })
    end
end

local function patchReloadWeaponAction_beforeAll()
    Events.OnGameBoot.Add(patchReloadWeaponAction_afterAll)
end

Events.OnGameBoot.Add(patchReloadWeaponAction_beforeAll)
