if not CharacterStat or not CharacterStat.UNHAPPINESS or not CharacterStat.BOREDOM then return end

-- zombie/characters/BodyDamage/BodyDamage.java
--   42.12    public float getUnhappynessLevel() / public void setUnhappynessLevel(float f)
--   42.12    public float getBoredomLevel()     / public void setBoredomLevel(float f)
--   42.13.1  -
--
-- used by 3508513470/mods/Support Goods - MyComputers
local function patchBodyDamage(playerIdx, playerObj)
    Events.OnCreatePlayer.Remove(patchBodyDamage)

    local bodyDamage = playerObj:getBodyDamage()

    if not bodyDamage.getUnhappynessLevel and not bodyDamage.setUnhappynessLevel then
        ZModUnbork.patch_metatable(bodyDamage, {
            getUnhappynessLevel = function(self)
                return self:getParentChar():getStats():get(CharacterStat.UNHAPPINESS)
            end,
            setUnhappynessLevel = function(self, f)
                return self:getParentChar():getStats():set(CharacterStat.UNHAPPINESS, f)
            end
        })
    end

    if not bodyDamage.getBoredomLevel and not bodyDamage.setBoredomLevel then
        ZModUnbork.patch_metatable(bodyDamage, {
            getBoredomLevel = function(self)
                return self:getParentChar():getStats():get(CharacterStat.BOREDOM)
            end,
            setBoredomLevel = function(self, f)
                return self:getParentChar():getStats():set(CharacterStat.BOREDOM, f)
            end,
        })
    end
end

-- need BodyDamage instance which can only be obtained from playerObj:getBodyDamage() after player creation
Events.OnCreatePlayer.Add(patchBodyDamage)
