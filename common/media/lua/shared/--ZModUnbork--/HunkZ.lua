-- mods revived:
--   Support Corps.3512993822

local function copyHottieZToHunkZ()
    local hottieZ = getItem("Base.HottieZ")
    local hunkZ   = getItem("Base.HunkZ")

    if hunkZ or not hottieZ then return end
    -- HunkZ   is absent
    -- HottieZ is present
    --   => copy HottieZ to HunkZ

    if not hottieZ.getLoadedScriptBodies then return end

    local scriptBodies = hottieZ:getLoadedScriptBodies()
    if not scriptBodies or scriptBodies:size() ~= 2 or scriptBodies:get(0) ~= "pz-vanilla" then return end

    local itemBody = scriptBodies:get(1)
    if type(itemBody) ~= "string" or not luautils.stringStarts(itemBody, "item HottieZ") then return end
    -- itemBody now contains smth like:
    --
    -- "item HottieZ
    --    {
    --        DisplayCategory = Literature,
    --        ItemType = base:literature,
    --        Weight = 0.5,
    --        Icon = MagazineNudie1,
    --        BoredomChange = -40,
    --        StressChange = -50,
    --        OnCreate = ItemCodeOnCreate.onCreateHottieZ,
    --        StaticModel = HottieZ,
    --        WorldStaticModel = HottieZGround,
    --        Tags = base:picturebook;base:ignorezombiedensity,
    --    }"

    local newBody = itemBody:gsub("item HottieZ", "item HunkZ") -- update only id!
    if not cloneItemType then return end

    local newType = cloneItemType("HunkZ", "Base.HottieZ")
    if not newType or not newType.Load then return end

    newType:Load("HunkZ", newBody)
    print("[ZModUnbork] HunkZ created by copying HottieZ")
end

Events.OnGameBoot.Add(copyHottieZToHunkZ)
