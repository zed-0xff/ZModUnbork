if not ItemType or not ItemType.NORMAL then
    print("[ZModUnbork] ItemType not found, skipping patch_itemtypes")
    return
end

local function checkItem(item)
    if not item.getItemType or not item.setItemType then return end

    local curType = item:getItemType()
    if curType and curType ~= ItemType.NORMAL then return end -- already fixed

    local scriptTbl = ZModUnbork.parse_item_script(item)
    if not scriptTbl or not scriptTbl.type then return end

    local type_upcase = scriptTbl.type:upper()
    local newType = ItemType[type_upcase]
    if newType then
        if newType ~= curType then
            print(string.format("[ZModUnbork] setting itemType to %-20s for %s", tostring(newType), item:getFullName()))
            item:setItemType(newType)
        end
    else
        print(string.format("[ZModUnbork] unknown itemType %-20s for %s", tostring(scriptTbl.type), item:getFullName()))
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
