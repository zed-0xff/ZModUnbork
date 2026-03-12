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
