-- mods unborked:
--   CombatText.2286124931
--   lots of mods using getVehicles()
if getCore():getGameVersion():isLessThan(GameVersion.parse("42.17")) then return end

-- zombie/iso/IsoMovingObject.java
--   42.16:
--     public void Move(Vector2 dir)
--     public void MoveUnmodded(Vector2 dir)
--   42.17:
--     public void moveUnmodded(float diffX, float diffY)
zdk.augment_all_metatables("moveUnmodded", {
    Move = function(self, dir)
        self:moveUnmodded(dir:getX(), dir:getY())
    end,

    MoveUnmodded = function(self, dir)
        self:moveUnmodded(dir:getX(), dir:getY())
    end,
})

-- zombie/iso/IsoCell.java
--   42.16: public ArrayList<BaseVehicle> getVehicles()
--   42.17: public Set<BaseVehicle> getVehicles()
-- see tags.lua

-- 42.16:
--   IsoGameCharacter
--     public boolean getIsNPC()
--     public boolean isNPC()
--     public void setIsNPC(boolean isAI)
--     public void setNPC(boolean newvalue)
-- 42.17:
--   IsoGameCharacter
--     public boolean isNpc()
--   IsoPlayer
--     public void setNpc(boolean isNpc)
zdk.augment_all_metatables("isNpc",  { getIsNPC = "isNpc", isNPC = "isNpc" })
zdk.augment_all_metatables("setNpc", { setNPC = "setNpc", setIsNPC = "setNpc" })
