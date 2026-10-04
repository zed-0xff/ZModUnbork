-- mods unborked:
--   ArsenalGunFighter.2297098490 (B41)
--   Brita_2.2460154811 (B41)
--   LeGourmetRevolution.2719327441 (B41)

-- XXX this file has to be in server/, not common/
local logger = zdk.Logger.new("ZModUnbork")

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

local function create_tree(root, tree, value)
    if type(root) ~= "table" or type(tree) ~= "table" then
        logger:warn("create_tree: expected table arguments, got %s and %s", type(root), type(tree))
    end
    local cur = root
    for i, k in ipairs(tree) do
        if not cur[k] then
            cur[k] = (i == #tree) and value or {}
        elseif type(cur[k]) ~= "table" then
            logger:warn("create_tree: expected table at '%s', got %s", k, type(cur[k]))
            return
        end
        cur = cur[k]
    end
end

--create_tree(SuburbsDistributions, {"all", "crate", "items"}, {})
--create_tree(SuburbsDistributions, {"motelroom", "sidetable", "items"}, {})
--create_tree(SuburbsDistributions, {"motelroom", "fridge",    "items"}, {})

local function installDistributionHack()
    if getmetatable(ProceduralDistributions) then
        logger:error("ProceduralDistributions already has a metatable, skipping distribution fix")
        return
    end
    -- a hack to prevent the game from throwing errors when it tries to access missing distribution lists
    setmetatable(ProceduralDistributions, {
        __index = function(_, k)
            return {}
        end
    })
    Events.OnPreDistributionMerge.Add(function()
        setmetatable(ProceduralDistributions, nil)
    end)
end


if Events and Events.OnPreDistributionMerge then
    installDistributionHack()
end
