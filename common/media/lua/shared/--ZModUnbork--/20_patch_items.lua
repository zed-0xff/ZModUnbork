-- mods unborked:
--   ArsenalGunFighter.2297098490 (B41)
--   Furry.2893930681
--   FurryApocalypseAnthroAccessories.3238978135
--   newcontainers_B42.3535295548
--   Support Corps.3512993822
--   Support Goods - MyComputers.3508513470
--   PFO_GUNRUNNER.3434691822

local logger = ZModUnbork.logger

if not ItemType or not ItemType.NORMAL then
    logger:warn("ItemType not found, skipping patch_itemtypes")
    return
end

local _cache = {}

-- typeName:
--   "Base.ShotgunShells"
--   "MagneticRound"
--   "base:bullets_9mm"
local function findAmmoType(typeName)
    local cached = _cache[typeName]
    if cached then return cached end

    local registry = Registries.AMMO_TYPE
    local result   = nil
    while not result do
        local underscore, camelCase
        if typeName:find(":") then
            underscore = typeName
            camelCase  = ZModUnbork.underscore_to_camel(typeName):gsub(":", ".") -- "base:bullets_9mm" -> "Base.Bullets9mm"
        elseif typeName:find("%.") then
            camelCase  = typeName
            underscore = ZModUnbork.camel_to_underscore(typeName):gsub("%.", ":") -- "Base.ShotgunShells" -> "base:shotgun_shells"
        elseif typeName:find("%u") then -- uppercase letter
            camelCase  = typeName
            underscore = ZModUnbork.camel_to_underscore(typeName)
        else
            underscore = typeName
            camelCase  = ZModUnbork.underscore_to_camel(typeName)
        end

        result = registry:get(ResourceLocation.of(underscore)) or registry:get(ResourceLocation.of(ZModUnbork.fix_id(underscore)))
        if result then break end

        local values = registry:values()
        for i=0,values:size()-1 do
            local key = values:get(i):getItemKey()
            if key == camelCase then
                result = values:get(i)
                break
            end
        end
        if result then break end

        if not registry.registerBase then -- enabled by ZBExhume41 mod
            local prefix = "ZModUnbork"
            if luautils.stringStarts(underscore, "base:") then
                underscore = prefix:lower() .. underscore:sub(5)
            elseif not underscore:find(":") then
                underscore = prefix:lower() .. ":" .. underscore
            end
            -- keep "Base." prefix because items are defined in item scripts with "Base." prefix
            --
            -- if luautils.stringStarts(camelCase,  "Base.") then
            --     camelCase = prefix .. camelCase:sub(5)
            -- elseif not camelCase:find("%.") then
            --     camelCase = prefix .. "." .. camelCase
            -- end
        end

        result = ZModUnbork.RegCache.find_or_create(registry, underscore, camelCase)
        break
    end

    _cache[typeName] = result
    return result
end

local _maxTypeLen = 15

local function checkItem(item)
    if not item.setItemType then return end

    local curType = item:getItemType()
    if curType and curType ~= ItemType.NORMAL then return end -- already fixed

    local newType = ItemType.NORMAL
    local scriptTbl = zdk.parse_item_script(item)
    if scriptTbl and scriptTbl.type then
        newType = ItemType.get(ResourceLocation.of(scriptTbl.type))
        if not newType then
            logger:warn("invalid itemType %S for %s, fallback to ItemType.NORMAL", scriptTbl.type, item:getFullName())
            newType = ItemType.NORMAL
        end
    end

    if newType == curType then return end

    _maxTypeLen = math.max(_maxTypeLen, string.len(tostring(newType)))
    if curType then
        logger:info("change itemType from %-*s to %-*s for %s", _maxTypeLen, curType, _maxTypeLen, newType, item:getFullName())
    else
        logger:info("set itemType to %-*s for %s", _maxTypeLen, newType, item:getFullName())
    end
    item:setItemType(newType)

    if newType == ItemType.WEAPON and scriptTbl.ammotype and item.getAmmoType and not item:getAmmoType() then
        local ammoType = findAmmoType(scriptTbl.ammotype)
        if ammoType then
            _maxTypeLen = math.max(_maxTypeLen, string.len(tostring(ammoType)))
            item:setAmmoType(ammoType)
            logger:info("set ammoType to %-*s for %s", _maxTypeLen, ammoType, item:getFullName())
        else
            logger:warn("invalid ammoType %S for %s", scriptTbl.ammotype, item:getFullName())
        end
    end
end

local function patchItemTypes()
    local items = ScriptManager.instance:getAllItems()
    for i=0,items:size()-1 do
        local item = items:get(i)
        if item:getModID() ~= ScriptManager.VanillaID then
            checkItem(item)
            if item:getItemType() == ItemType.LITERATURE then
                local scriptTbl = zdk.parse_item_script(item)
                -- 41.78: TeachedRecipes
                -- 42.12: LearnedRecipes
                if scriptTbl and scriptTbl.teachedrecipes then
                    logger:info("set LearnedRecipes to %S for %s", scriptTbl.teachedrecipes, item:getFullName())
                    item:DoParam("LearnedRecipes", scriptTbl.teachedrecipes)
                end
            end
        end
    end
end

Events.OnGameBoot.Add(patchItemTypes)
