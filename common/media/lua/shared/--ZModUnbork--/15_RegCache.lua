ZModUnbork = ZModUnbork or {}
ZModUnbork.RegCache = {}

local logger = ZModUnbork.logger
local _cache = {}

function ZModUnbork.RegCache.get_cache(registry)
    if not registry then
        logger:error("RegCache.get_cache: registry is nil")
        return nil
    end

    local cache = _cache[registry]
    if not cache then
        cache = {}
        _cache[registry] = cache
    end
    return cache
end

-- AmmoType, ItemBodyLocation, etc.
local function find_regClass(registry, id)
    if not registry or not registry.values or registry:values():isEmpty() then
        logger:error("find_regClass(%s, %S): invalid registry", registry, id)
        return nil
    end

    local firstValue = registry:values():get(0)
    local className  = getClassSimpleName(firstValue)
    local regClass   = _G[className]

    if not regClass then
        logger:error("find_regClass(%s, %S): registry class %S not found, firstValue=%S", registry, id, className, firstValue)
        return nil
    end

    return regClass
end

function ZModUnbork.RegCache.find(registry, id)
    if not registry or type(id) ~= "string" then
        logger:error("RegCache.find: invalid arguments, registry=%S, id=%S", registry, id)
        return nil, nil
    end

    local regClass = find_regClass(registry, id)
    if not regClass then return nil, nil end

    local needle = regClass.get(ResourceLocation.of(id))
    if needle then return needle, regClass end

    local id2 = ZModUnbork.fix_id(id)
    if id2 ~= id then
        needle = regClass.get(ResourceLocation.of(id2))
        if needle then return needle, regClass end
    end

    local sep_pos = id:find("[:.]")
    if sep_pos then
        local prefix = id:sub(1, sep_pos-1)
        if prefix:lower() == "base" and #id > sep_pos then
            -- remove 'base.' or 'base:' and try again
            return ZModUnbork.RegCache.find(registry, id:sub(sep_pos+1))
        end
    end
    return nil, regClass
end

-- convert String id to registry id, register if not exists, and cache for future use
function ZModUnbork.RegCache.find_or_create(registry, id, ...)
    if not registry or type(id) ~= "string" then
        logger:error("RegCache.find_or_create: invalid arguments, registry=%S, id=%S", registry, id)
        return nil
    end

    local cache  = ZModUnbork.RegCache.get_cache(registry)
    local lowKey = id:lower()

    local cached = cache[lowKey]
    if cached then return cached end

    -- repeat lookups on cache misses, resources may be available later after other mods load
    local needle, regClass = ZModUnbork.RegCache.find(registry, id)
    if not regClass then return nil end

    while not needle do
        -- find failed, try to register

        -- strip mistyped "base." prefix
        if id:sub(1,5):lower() == "base." then
            local id2 = id:sub(6)
            ZModUnbork.log_once("RegCache.find_or_create: %S -> %S", id, id2)
            id = id2
        end

        -- enabled by ZBExhume41 mod
        if regClass.registerBase then
            needle = regClass.registerBase(id, ...)
            if needle then break end
        end

        -- registerBase is not available, and register() will fail if id has "base:" prefix
        if id:sub(1,5):lower() == "base:" then
            local id2 = id:sub(6)
            ZModUnbork.log_once("RegCache.find_or_create: %S -> %S", id, id2)
            id = id2
        end

        needle = regClass.register(ZModUnbork.fix_id(id), ...)
        break
    end

    cache[lowKey] = needle -- still may be nil
    return needle
end
