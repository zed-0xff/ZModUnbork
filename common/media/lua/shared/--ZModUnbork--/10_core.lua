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
    if not table.isempty(patch) then zdk.patch_metatable(obj, patch) end
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
function ZModUnbork.log_origin_once(origin)
    if not origin then return end

    local line = origin.line and (":" .. tostring(origin.line)) or ""
    local origin_str = tostring(origin.fname) .. line
    if not _logged_origins[origin_str] then
        _logged_origins[origin_str] = true
        logger:info("    called from %s", origin_str)
    end
end

