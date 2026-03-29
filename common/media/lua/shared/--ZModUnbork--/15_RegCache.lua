ZModUnbork = ZModUnbork or {}
ZModUnbork.RegCache = {}

local logger = ZModUnbork.logger
local _cache = {}

function ZModUnbork.RegCache.get(registry)
    if not registry then
        logger:error("RegCache.get: registry is nil")
        return nil
    end

    local cache = _cache[registry]
    if not cache then
        cache = {}
        _cache[registry] = cache
    end
    return cache
end

-- convert String id to registry id, register if not exists, and cache for future use
-- XXX: what is more reliable? Registries.AMMO_TYPE or AmmoType? maybe pass both and use whichever works?
function ZModUnbork.RegCache.convert_id(registry, id, ...)
    if not registry or not registry.values or registry:values():isEmpty() then
        logger:error("convert_id(%s): invalid registry %s", id, registry)
        return nil
    end

    local firstValue = registry:values():get(0)
    local className  = getClassSimpleName(firstValue)
    local regClass   = _G[className]                  -- AmmoType, ItemBodyLocation, etc.

    if not regClass then
        logger:error("convert_id(%s): registry class %s not found, firstValue=%s", id, className, firstValue)
        return nil
    end
    
    local cache   = ZModUnbork.RegCache.get(registry)
    local origKey = id
    local lowKey  = origKey:lower()

    if cache[lowKey] == nil then -- values are object or false
        cache[lowKey] = false    -- do not spam log with errors if register fails

        -- regClass.get() is equal to registry.get()
        local loc = regClass.get(ResourceLocation.of(id)) -- try standard locations first - Furry: bodyGroup:indexOf("Bandage")
        if not loc then
            local fullID = ZModUnbork.fix_id(id) -- add default prefix if missing - Furry: "Bandage" -> "ZModUnbork:Bandage"
            loc = regClass.get(ResourceLocation.of(fullID)) or regClass.register(fullID, ...)
        end
        cache[lowKey] = loc or false
    end

    return cache[lowKey] or nil
end
