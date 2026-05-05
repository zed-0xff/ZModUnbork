ZModUnbork = ZModUnbork or {}

ZModUnbork.MOD_ID         = "ZModUnbork"
ZModUnbork.DEFAULT_PREFIX = ZModUnbork.MOD_ID
ZModUnbork.logger         = zdk.Logger.new(ZModUnbork.MOD_ID)

local logger = ZModUnbork.logger

-- Add alias for method: if obj has nameA, add nameB that calls nameA (and vice versa).
-- Only one of (name_a, name_b) should exist on obj; the other is patched in.
function ZModUnbork.patch_method_alias(klass, name_a, name_b)
    if not klass or not name_a or not name_b then return end

    if klass == "*" then
        zdk.augment_all_metatables(name_a, { [name_b] = name_a })
        zdk.augment_all_metatables(name_b, { [name_a] = name_b })
    else
        -- augment_metatable() will only patch if the method doesn't already exist, so this is safe to call even if both name_a and name_b already exist on klass
        zdk.augment_metatable(klass, { [name_a] = name_b, [name_b] = name_a })
    end
end

function ZModUnbork.fix_id(id)
    if type(id) ~= "string" then
        logger:error("fix_id: expected string, got %s", type(id))
        return id
    end
    if id:contains(":") then return id end
    return ZModUnbork.DEFAULT_PREFIX .. ":" .. id
end

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

-- CamelCase -> under_score
-- "Base:Bullets9mm" -> "base:bullets_9mm"
function ZModUnbork.camel_to_underscore(s)
  local parts = {}

  for part in string.gmatch(s, "[^%.]+") do
    local p = part
      :gsub("(%l)(%u)", "%1_%2")      -- aB -> a_B
      :gsub("(%u)(%u%l)", "%1_%2")    -- HTTPServer -> HTTP_Server
      :gsub("(%a)(%d)", "%1_%2")      -- a1 -> a_1
      :lower()

    table.insert(parts, p)
  end

  return table.concat(parts, ".")
end

-- under_score -> CamelCase
-- "base:bullets_9mm" -> "Base:Bullets9mm"
function ZModUnbork.underscore_to_camel(s)
  s = string.lower(s)

  local out = {}
  local upper_next = true  -- capitalize first char

  for i = 1, #s do
    local c = string.sub(s, i, i)

    if c == "_" then
      upper_next = true -- consume "_"
    elseif string.match(c, "%w") then
      if upper_next then
        table.insert(out, string.upper(c))
        upper_next = false
      else
        table.insert(out, c)
      end
    else
      -- punctuation: keep it, but trigger capitalization
      table.insert(out, c)
      upper_next = true
    end
  end

  return table.concat(out)
end
