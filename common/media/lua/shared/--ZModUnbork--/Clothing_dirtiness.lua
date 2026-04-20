-- zombie/inventory/types/Clothing.java
--   42.13.2  public float getDirtyness() / setDirtyness(float)
--   42.14    public float getDirtiness() / setDirtiness(float)
ZModUnbork.patch_method_alias("*", "getDirtiness", "getDirtyness")
ZModUnbork.patch_method_alias("*", "setDirtiness", "setDirtyness")
