local function get_clothing_item()
    local items = get_player():getInventory():getItems()
    for i=0, items:size()-1 do
        local item = items:get(i)
        if instanceof(item, "Clothing") then
            return item
        end
    end
end

describe("Clothing", function()
    local item = get_clothing_item()

    it("should have test item", function()
        assert(item)
    end)

    describe("getDirt[iy]ness()", function()
        it("should have getDirtiness method", function()
            assert.is_function(item.getDirtiness)
        end)

        it("should have getDirtyness method", function()
            assert.is_function(item.getDirtyness)
        end)

        it("getDirtiness and getDirtyness should return the same value", function()
            local dirtiness = item:getDirtiness()
            local dirtyness = item:getDirtyness()
            assert.eq(dirtiness, dirtyness)
        end)
    end)

    describe("getTags():get(0)", function()
        it("should return a string", function()
            assert.is_string(item:getTags():get(0))
        end)
    end)

    describe("getScriptItem():getTypeString()", function()
        it("should return 'Clothing'", function()
            assert.eq("Clothing", item:getScriptItem():getTypeString())
        end)
    end)
end)

return ZBSpec.runAsync()
