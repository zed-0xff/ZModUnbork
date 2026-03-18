ZModUnbork = ZModUnbork or {}

function ZModUnbork.patch_metatable(obj, functbl)
    if not obj then return end

    local mt = getmetatable(obj)
    if not mt then return end

    local index = mt.__index
    if not index then return end

    for methodName, func in pairs(functbl) do
        if not index[methodName] then -- patch only if method is not already defined
            index[methodName] = func
        end
    end
end

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
    if not table.isempty(patch) then ZModUnbork.patch_metatable(obj, patch) end
end

-- returns smth like: (all lowercase and numbers as strings!)
-- {
--            "closesound" => "closekeyring",
--      "worldstaticmodel" => "keyring_rubberduck",
--             "opensound" => "openkeyring",
--            "putinsound" => "storeitemkeyring",
--                  "icon" => "keychain_rubberduck",
--               "tooltip" => "tooltip_item_duck",
--                "weight" => "0.05",
--       "displaycategory" => "duck",
--            "metalvalue" => "5.0",
--       "weightreduction" => "85",
--              "capacity" => "1",
--                  "tags" => "base:keyring;base:neverempty;base:morewhennozombies;base:bagsfillexception;base:ignorezombiedensity;base:ismemento",
--    "acceptitemfunction" => "acceptitemfunction.keyring",
--              "itemtype" => "base:container"
-- }
function ZModUnbork.parse_item_script(item)
    local lines = nil
    if item.getScriptLines then
        lines = item:getScriptLines()
    end

    if not lines or lines:size() == 0 and item.getScriptItem then
        local scriptItem = item:getScriptItem()
        if scriptItem then
            lines = scriptItem:getScriptLines()
        end
    end

    if not lines or lines:size() == 0 then
        print("[ZModUnbork] parse_item_script: no script lines for " .. tostring(item))
        return {}
    end

    local result = {}
    for i=0,lines:size()-1 do
        local line = lines:get(i):gsub("[\t ,]", ""):lower()
        local a = line:split("=")
        if a and #a == 2 then
            result[a[1]] = a[2]
        end
    end
    return result
end
