ZModUnbork = ZModUnbork or {}

ZModUnbork.MOD_ID         = "ZModUnbork"
ZModUnbork.DEFAULT_PREFIX = "ZModUnbork"
ZModUnbork.logger         = zdk.Logger.new("ZModUnbork")

local logger = ZModUnbork.logger

-- Add alias for method: if obj has nameA, add nameB that calls nameA (and vice versa).
-- Only one of (name_a, name_b) should exist on obj; the other is patched in.
function ZModUnbork.patch_method_alias(obj, name_a, name_b)
    if not obj or not name_a or not name_b then return end
    local patch = {}
    if obj[name_a] then
        patch[name_b] = obj[name_a]
    elseif obj[name_b] then
        patch[name_a] = obj[name_b]
    end
    if not table.isempty(patch) then zdk.augment_metatable(obj, patch) end
end

function ZModUnbork.fix_id(id)
    if type(id) ~= "string" then
        logger:error("fix_id: expected string, got %s", type(id))
        return id
    end
    if id:contains(":") then return id end
    return ZModUnbork.DEFAULT_PREFIX .. ":" .. id
end

--local _prefix_cache = {}
--local function origin2prefix(origin)
--    if not origin or not origin.fname then return DEFAULT_PREFIX end
--
--    if _prefix_cache[origin.fname] then
--        return _prefix_cache[origin.fname]
--    end
--
--    local prefix  = DEFAULT_PREFIX
--    local modInfo = zdk.fname2mod(origin.fname)
--    if modInfo then
--        prefix = modInfo:getId():gsub("\\", "") -- remove heading slash from pre-42.15 mod ids
--    end
--
--    _prefix_cache[origin.fname] = prefix
--    return prefix
--end

local _logged_origins = {}
local function log(level, fmt, ...)
    local origin = zdk.get_call_origin(ZModUnbork.MOD_ID)
    if not origin then return end

    local origin_str = origin.short_str or (tostring(origin.fname) .. (origin.line and (":" .. tostring(origin.line)) or ""))
    local log_key = origin_str .. "|" .. tostring(level)
    if _logged_origins[log_key] then return end

    _logged_origins[log_key] = true
    logger:log(level, "%s -- " .. tostring(fmt), origin_str, ...)
end

function ZModUnbork.log_once (fmt, ...) log(logger.INFO, fmt, ...) end
function ZModUnbork.warn_once(fmt, ...) log(logger.WARN, fmt, ...) end

local function process_all_metatables(condKey, func)
    for klass, mt in pairs(__classmetatables) do
        local index = mt.__index
        -- XXX have to use rawget() here to avoid calling any metamethods that regular tbl['hasTrait'] or tbl.hasTrait might potentially trigger
        -- random mods break in random places if "tbl['hasTrait']" or "tbl.hasTrait" is used here
        if type(index) == "table" and rawget(index, condKey) then
            func(klass)
        end
    end
end

-- add new methods if they not already exist
function ZModUnbork.augment_all_metatables(condKey, tbl)
    process_all_metatables(condKey, function(klass)
        zdk.augment_metatable(klass, tbl)
    end)
end

-- patch existing methods
function ZModUnbork.patch_all_metatables(condKey, tbl)
    process_all_metatables(condKey, function(klass)
        zdk.hook({
            [klass] = tbl
        })
    end)
end
