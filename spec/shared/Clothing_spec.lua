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

        it("should refer to the same method", function()
            local m1 = item.getDirtiness
            local m2 = item.getDirtyness
            assert.eq(m1, m2)
        end)

        it("should return the same value", function()
            local dirtiness = item:getDirtiness()
            local dirtyness = item:getDirtyness()
            assert.eq(dirtiness, dirtyness)
        end)
    end)

    describe("setDirt[iy]ness()", function()
        it("should have setDirtiness method", function()
            assert.is_function(item.setDirtiness)
        end)

        it("should have setDirtyness method", function()
            assert.is_function(item.setDirtyness)
        end)

        it("should refer to the same method", function()
            local m1 = item.setDirtiness
            local m2 = item.setDirtyness
            assert.eq(m1, m2)
        end)
    end)

    describe("getTags():get(0)", function()
        local tags = item:getTags()

        describe("get(0)", function()
            it("should return a string", function()
                assert.is_string(tags:get(0))
            end)
        end)

        describe("size()", function()
            it("should return positive number", function()
                assert.gt(tags:size(), 0)
            end)
        end)
    end)

    describe("getScriptItem():getTypeString()", function()
        it("should return 'Clothing'", function()
            assert.eq("Clothing", item:getScriptItem():getTypeString())
        end)
    end)
end)

return ZBSpec.runAsync()
