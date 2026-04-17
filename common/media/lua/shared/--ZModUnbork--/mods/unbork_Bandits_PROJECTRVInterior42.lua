if not getActivatedMods():contains("Bandits2") then return end
if not getActivatedMods():contains("PROJECTRVInterior42") then return end

local rvf = nil

function ZModUnbork.playerInsideInterior(player)
    ZModUnbork.log_once("RVInterior.playerInsideInterior()")
    if CheckIfInRV then
        -- MP
        return CheckIfInRV(player)
    else
        if rvf == nil then
            rvf = require("RVClientSP") or false
        end
        if rvf and rvf.CheckIfInRV then
            return rvf.CheckIfInRV(player)
        end
    end
end

local function preventBanditsInRVArea()
    if RVInterior and RVInterior.playerInsideInterior then
        -- patch existing function
        zdk.hook({
            RVInterior = {
                playerInsideInterior = function(orig, player, ...)
                    return orig(player, ...) or ZModUnbork.playerInsideInterior(player)
                end
            }
        })
    else
        -- define our own
        RVInterior = RVInterior or {}
        RVInterior.playerInsideInterior = ZModUnbork.playerInsideInterior
    end
end

Events.OnGameBoot.Add(preventBanditsInRVArea)
