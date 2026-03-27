local patch_method_alias = ZModUnbork.patch_method_alias
local item = instanceItem("Base.Belt2")

-- zombie/inventory/types/Clothing.java
--   42.13.2  public float getDirtyness() / setDirtyness(float)
--   42.14    public float getDirtiness() / setDirtiness(float)
patch_method_alias(item, "getDirtiness", "getDirtyness")
patch_method_alias(item, "setDirtiness", "setDirtyness")

-- class AlarmClockClothing extends Clothing
local clock = instanceItem("Base.WristWatch_Left_ClassicGold")
if clock then
    -- fixes ItemComparison mod errors when showing tooltip for watches
    patch_method_alias(clock, "getDirtiness", "getDirtyness")
    patch_method_alias(clock, "setDirtiness", "setDirtyness")
end
