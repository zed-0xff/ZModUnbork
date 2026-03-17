local TYPE_MAP = {
    ["type=container"] = ItemType.CONTAINER,
    ["type=drainable"] = ItemType.DRAINABLE,
}

local function checkItem(item)
    if item:getItemType() ~= ItemType.NORMAL then return end
    local lines= item:getScriptLines()
    for i=0,lines:size()-1 do
        local line = lines:get(i):gsub("[\t ,]", ""):lower()
        local newType = TYPE_MAP[line]
        if newType then
            print("[ZModUnbork] " .. item:getFullName() .. ":setting itemType to " .. tostring(newType))
            item:setItemType(newType)
            break
        end
    end
end


local function patchItemTypes()
    local items = ScriptManager.instance:getAllItems()
    for i=0,items:size()-1 do
        local item = items:get(i)
        if item:getModID() ~= ScriptManager.VanillaID then
            checkItem(item)
        end
    end
end

Events.OnInitWorld.Add(patchItemTypes)
