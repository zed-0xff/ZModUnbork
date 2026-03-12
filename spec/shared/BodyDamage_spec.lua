describe("BodyDamage", function()
    local bodyDamage = get_player():get_body_damage()

    describe("getUnhappynessLevel", function()
        it("is a function", function()
            assert.is_function(bodyDamage[subject])
        end)

        it("returns value of CharacterStat.UNHAPPINESS", function()
            local expected = 4.0
            get_player():getStats():set(CharacterStat.UNHAPPINESS, expected)
            assert.eq(expected, bodyDamage:getUnhappynessLevel())
        end)
    end)

    describe("setUnhappynessLevel", function()
        it("is a function", function()
            assert.is_function(bodyDamage[subject])
        end)

        it("sets value of CharacterStat.UNHAPPINESS", function()
            local expected = 8.0
            bodyDamage:setUnhappynessLevel(expected)
            assert.eq(expected, get_player():getStats():get(CharacterStat.UNHAPPINESS))
        end)
    end)

    describe("getBoredomLevel", function()
        it("is a function", function()
            assert.is_function(bodyDamage[subject])
        end)

        it("returns value of CharacterStat.BOREDOM", function()
            local expected = 4.0
            get_player():getStats():set(CharacterStat.BOREDOM, expected)
            assert.eq(expected, bodyDamage:getBoredomLevel())
        end)
    end)

    describe("setBoredomLevel", function()
        it("is a function", function()
            assert.is_function(bodyDamage[subject])
        end)

        it("sets value of CharacterStat.BOREDOM", function()
            local expected = 8.0
            bodyDamage:setBoredomLevel(expected)
            assert.eq(expected, get_player():getStats():get(CharacterStat.BOREDOM))
        end)
    end)
end

return ZBSpec.runAsync()
