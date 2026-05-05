ZModUnbork = ZModUnbork or {}

local _cache  = nil
local _nfiles = 0
local _nlines = 0

local PREFIXES = {
    "ContextMenu_",
    "IGUI_",
    "ItemName_",
    "Recipe_",
    "Sandbox_",
    "Tooltip_",
    "UI_",
}

-- has to be global for getText/getTextOrNull hooks
function has_supported_prefix(key)
    if type(key) ~= "string" then return false end

    for _, prefix in ipairs(PREFIXES) do
        if luautils.stringStarts(key, prefix) then return true end
    end
    return false
end

local function process_line(line)
    if not has_supported_prefix(line) then return end
    local eq_pos = line:find("=")
    if not eq_pos then return end

    local key   = line:sub(1, eq_pos - 1):trim()
    local value = line:sub(eq_pos + 1):trim()
    if not key or not value or key == "" or value == "" then return end
    if value == "{" then return end -- very first file line is "IGUI_ = {"

    if luautils.stringEnds(value, ",") then
        value = value:sub(1, -2):trim()
    end

    if luautils.stringStarts(value, '"') then
        value = value:sub(2)
    end
    if luautils.stringEnds(value, '"') then
        value = value:sub(1, -2)
    end

    _cache[key] = value
    _nlines = _nlines + 1
end

local function process_file(mod_id, fname)
    local reader = getModFileReader(mod_id, fname, false)
    if not reader then return end

    local line = reader:readLine()
    while line ~= nil do
        line = line:trim():gsub("\t", " ")
        process_line(line)

        line = reader:readLine()
    end
    reader:close()
    _nfiles = _nfiles + 1
end

local function init_cache()
    _cache = {}

    local mods = getActivatedMods()
    for i = 0, mods:size() - 1 do
        local mod_id = mods:get(i)
        process_file(mod_id, "media/lua/shared/Translate/EN/ContextMenu_EN.txt")
        process_file(mod_id, "media/lua/shared/Translate/EN/IG_UI_EN.txt")
        process_file(mod_id, "media/lua/shared/Translate/EN/ItemName_EN.txt")
        process_file(mod_id, "media/lua/shared/Translate/EN/Recipes_EN.txt")
        process_file(mod_id, "media/lua/shared/Translate/EN/Sandbox_EN.txt")
        process_file(mod_id, "media/lua/shared/Translate/EN/Tooltip_EN.txt")
        process_file(mod_id, "media/lua/shared/Translate/EN/UI_EN.txt")
    end

    ZModUnbork.logger:debug("Loaded %d translations from %d files", _nlines, _nfiles)
    ZModUnbork.stats.translation_lines = _nlines
    ZModUnbork.stats.translation_files = _nfiles
end

local function try_translate(key)
    if type(key) ~= "string" then return key end
    if not has_supported_prefix(key) then return key end

    if not _cache then init_cache() end

    local translated = _cache[key]
    if translated then
        ZModUnbork.clog_once('getText', 'translated "%s" -> "%s"', key, translated)
        return translated
    end
    return key
end

local function try_translate_item(result, fullType)
    if type(result) ~= "string" or type(fullType) ~= "string" then return result end
    if not luautils.stringStarts(result, fullType)            then return result end

    return try_translate("ItemName_" .. fullType)
end

-- Item, what else?
zdk.patch_all_metatables('getFullName', {
    getDisplayName = function(orig, self, ...) return try_translate_item(orig(self, ...), self:getFullName()) end
})

-- InventoryItem, Clothing, HandWeapon, ...
zdk.patch_all_metatables('getFullType', {
    getDisplayName      = function(orig, self, ...) return try_translate_item(orig(self, ...), self:getFullType()) end,
    getName             = function(orig, self, ...) return try_translate_item(orig(self, ...), self:getFullType()) end,
    getCustomMenuOption = function(orig, ...)       return try_translate(orig(...)) end,
})

--- tooltips

local function checkItem(item)
    local tooltip = item.getTooltip and item:getTooltip()
    if type(tooltip) ~= "string" then return end
    if not luautils.stringStarts(tooltip, "Tooltip_") then return end
    if getTextOrNull(tooltip) then return end -- proper translation already exists

    if not _cache then init_cache() end

    local actual_tooltip = _cache[tooltip]
    if not actual_tooltip then return end

    ZModUnbork.clog("tooltips", "fixing tooltip for %s", item:getFullName())
    item:DoParam("Tooltip", tostring(actual_tooltip))
end

local function patchItemTooltips()
    local items = ScriptManager.instance:getAllItems()
    for i=0,items:size()-1 do
        local item = items:get(i)
        if item:getModID() ~= ScriptManager.VanillaID then
            checkItem(item)
        end
    end
end

patchItemTooltips() -- XXX has to be run before the getTextOrNull() is hooked!

--- hooks

zdk.hook({
    _G = {
        getText = function(orig, key, ...)
            local result = orig(key, ...)
            if result ~= key then return result end

            return try_translate(key)
        end,

        getTextOrNull = function(orig, key, ...)
            local result = orig(key, ...)
            if result ~= nil then return result end

            local translated = try_translate(key)
            return (translated ~= key and translated) or nil
        end,

        getItemNameFromFullType = function(orig, fullType, ...)
            return try_translate_item(orig(fullType, ...), fullType)
        end,
    },
})

