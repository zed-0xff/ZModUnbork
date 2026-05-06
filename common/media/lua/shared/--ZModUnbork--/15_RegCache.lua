ZModUnbork = ZModUnbork or {}
ZModUnbork.RegCache = {}

local logger = ZModUnbork.logger
local _cache = {}
local _regClassByRegistry = {} -- registry userdata -> regClass table (e.g. CharacterTrait); only set on success so empty/missing-class cases retry

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
    if not registry then
        logger:error("find_regClass(%s, %S): invalid registry", registry, id)
        return nil
    end

    local hit = _regClassByRegistry[registry]
    if hit then return hit end

    if not registry.values or registry:values():isEmpty() then
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

    _regClassByRegistry[registry] = regClass
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

local function class2str(x)
    if type(x) == "table" and x.class then
        -- getClassSimpleName(AmmoType)       => "KahluaTableImpl"
        -- getClassSimpleName(AmmoType.class) => "Class"
        -- tostring(AmmoType)                 => "table 0x1776177210"
        -- tostring(AmmoType.class)           => "class zombie.scripting.objects.AmmoType"
        local a = tostring(AmmoType.class):split("[.]")
        return a[#a] -- "AmmoType"
    else
        return tostring(x)
    end
end

-- optional registerArgs     is passed as extra args to register()
-- optional registerBaseArgs is passed as extra args to registerBase(), nil = copy from registerArgs, false = don't call registerBase()
-- optional regClass         is passed from find_or_create() to avoid redundant registry lookup
function ZModUnbork.RegCache.create(registry, id, registerArgs, registerBaseArgs, regClass)
    if not registry or type(id) ~= "string" then
        logger:error("RegCache.create: invalid arguments, registry=%S, id=%S", registry, id)
        return nil
    end

    registerArgs = registerArgs or {}
    if type(registerArgs) ~= "table" then
        logger:error("RegCache.create: invalid registerArgs=%S", registerArgs)
        return nil
    end
    if registerBaseArgs == nil then
        registerBaseArgs = registerArgs
    elseif registerBaseArgs ~= false and type(registerBaseArgs) ~= "table" then
        logger:error("RegCache.create: invalid registerBaseArgs=%S", registerBaseArgs)
        return nil
    end

    -- strip mistyped "base." prefix
    if id:sub(1,5):lower() == "base." then
        local id2 = id:sub(6)
        ZModUnbork.clog_once('fix_base', "RegCache.create: %S -> %S", id, id2)
        id = id2
    end

    regClass = regClass or find_regClass(registry, id)
    if not regClass then return nil end

    -- enabled by ZBExhume41 mod
    if regClass.registerBase and registerBaseArgs ~= false then
        local result = regClass.registerBase(id, unpack(registerBaseArgs))
        if result then
            ZModUnbork.clog('registerBase', "%s.registerBase(%s, %s) => %s", class2str(regClass), id, registerBaseArgs, result)
            return result
        end
    end

    -- registerBase is not available, and register() will fail if id has "base:" prefix
    if id:sub(1,5):lower() == "base:" then
        local id2 = id:sub(6)
        ZModUnbork.clog_once('fix_base', "RegCache.create: %S -> %S", id, id2)
        id = id2
    end

    local result = regClass.register(ZModUnbork.fix_id(id), unpack(registerArgs))
    if result then ZModUnbork.clog('register', "%s.register(%s, %s) => %s", class2str(regClass), id, registerArgs, result) end

    return result
end

-- convert String id to registry id, register if not exists, and cache for future use
function ZModUnbork.RegCache.find_or_create(registry, id, registerArgs, registerBaseArgs)
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
    if not needle then
        if not regClass then return nil end
        needle = ZModUnbork.RegCache.create(registry, id, registerArgs, registerBaseArgs, regClass)
    end

    cache[lowKey] = needle -- still may be nil
    return needle
end
