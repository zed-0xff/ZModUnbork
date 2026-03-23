ZModUnbork = ZModUnbork or {}

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
