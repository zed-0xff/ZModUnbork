local function checkItem(item)
    if item:getItemType() ~= ItemType.NORMAL then return end
    local lines= item:getScriptLines()
    for i=0,lines:size()-1 do
        local line = lines:get(i):gsub("[\t ,]", "")
        if line == "Type=Drainable" then
            print("[ZModUnbork] setting itemType to ItemType.DRAINABLE for " .. item:getFullName())
            item:setItemType(ItemType.DRAINABLE)
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
