if RVInterior then return end
if not getActivatedMods():contains("Bandits2") then return end
if not getActivatedMods():contains("PROJECTRVInterior42") then return end

local rvf = nil
if not rvf then return end

RVInterior = {}
function RVInterior.playerInsideInterior(player)
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
