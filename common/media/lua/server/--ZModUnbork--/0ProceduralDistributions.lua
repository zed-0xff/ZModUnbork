-- mods unborked:
--   ArsenalGunFighter.2297098490 (B41) -- fails to load bc it overrides default PZ weapon animation XMLs
--   Brita_2.2460154811 (B41)

-- XXX this file has to be in server/, not common/

require "Items/ProceduralDistributions"
if not ProceduralDistributions or not ProceduralDistributions.list then return end

-- vanilla ProceduralDistributions.lua defines following aliases, but they are effectively ignored due to the way lua parses table definitions
local aliases = {
    Bakery              = "BakeryMisc",
    BedroomSideTable    = "BedroomSidetable",
    WardrobeMan         = "WardrobeGeneric",
    WardrobeManClassy   = "WardrobeClassy",
    WardrobeWoman       = "WardrobeGeneric",
    WardrobeWomanClassy = "WardrobeClassy",
}

for k,v in pairs(aliases) do
    if ProceduralDistributions.list[v] and not ProceduralDistributions.list[k] then
        ZModUnbork.clog('distributions', "ProceduralDistributions: aliasing '%s' to '%s'", k, v)
        ProceduralDistributions.list[k] = ProceduralDistributions.list[v]
    end
end
