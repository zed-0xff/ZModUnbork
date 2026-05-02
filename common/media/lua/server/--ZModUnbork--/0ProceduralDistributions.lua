-- mods unborked:
--   Brita_2.2460154811 (B41)

-- XXX this file has to be in server/, not common/

require "Items/ProceduralDistributions"
if not ProceduralDistributions or not ProceduralDistributions.list then return end

-- vanilla ProceduralDistributions.lua defines following aliases, but they are effectively ignored due to the way lua parses table definitions
local aliases = {
    Bakery              = "BakeryMisc",
    WardrobeManClassy   = "WardrobeClassy",
    WardrobeWoman       = "WardrobeGeneric",
    WardrobeWomanClassy = "WardrobeClassy",
}

for k,v in pairs(aliases) do
    if ProceduralDistributions.list[v] and not ProceduralDistributions.list[k] then
        ZModUnbork.logger:info("ProceduralDistributions: aliasing '%s' to '%s'", k, v)
        ProceduralDistributions.list[k] = ProceduralDistributions.list[v]
    end
end
