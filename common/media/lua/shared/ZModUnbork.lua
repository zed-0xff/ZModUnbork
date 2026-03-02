local function patch_metatable(obj, functbl)
    if not obj then return end

    local mt = getmetatable(obj)
    if not mt then return end

    local index = mt.__index
    if not index then return end

    for methodName, func in pairs(functbl) do
        if not index[k] then
            index[methodName] = func
        end
    end
end

local item = instanceItem("Base.Belt2")

-- zombie/inventory/types/Clothing.java
--   42.13.1  public float getDirtiness()
--   42.13.2  public float getDirtyness()
patch_metatable(item, {
    -- class: zombie.inventory.types.Clothing
    getDirtyness = function(self)
        return self:getDirtiness()
    end
})

-- zombie/scripting/objects/Item.java
--   42.12    public ArrayList<String> getTags()
--   42.13.1  public Set<ItemTag>      getTags()
patch_metatable(item:getTags(), {
    get = function(self, index)
        return self:toArray()[index+1]
    end
})

-- zombie/scripting/objects/Item.java
--   42.12    public String   getTypeString()
--   42.13.1  public ItemType getItemType()        XXX NOT EQUAL TO getStringItemType() !
patch_metatable(item:getScriptItem(), {
    getTypeString = function(self)
        if self.getItemType then
            local itemType = self:getItemType()
            if ItemType.DRAINABLE and ItemType.DRAINABLE == itemType then
                return "Drainable"
            end
            -- TODO: more types
        end
    end
})
