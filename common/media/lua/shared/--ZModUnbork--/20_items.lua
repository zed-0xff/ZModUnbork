-- mods unborked:
--   ArsenalGunFighter.2297098490 (B41)
--   Furry.2893930681
--   FurryApocalypseAnthroAccessories.3238978135
--   newcontainers_B42.3535295548
--   Support Corps.3512993822
--   Support Goods - MyComputers.3508513470
--   PFO_GUNRUNNER.3434691822

local logger = ZModUnbork.logger

if not ItemType or not ItemType.NORMAL then logger:warn("ItemType not found, skipping 20_items.lua"); return end
if type(ItemKey) ~= "table" or not ItemKey.getByName or not ItemKey.new then logger:warn("ItemKey not found, skipping 20_items.lua"); return end

local EMPTY_OPTIONAL = ItemKey.getByName("__empty" .. tostring(getRandomUUID()))
local ITEMKEY_BASE_PREFIX = "Base."

local function gatherBaseItemKeys()
    local result = {}
    for k, v in pairs(ItemKey) do
        if type(v) == "table" then
            for _, itemKey in pairs(v) do
                if instanceof(itemKey, "ItemKey") and zdk.is_callable(itemKey.id) then
                    local id = itemKey:id() -- "Axe"
                    if type(id) == "string" then
                        local fullId = luautils.stringStarts(id, ITEMKEY_BASE_PREFIX) and id or (ITEMKEY_BASE_PREFIX .. id) -- "Axe" -> "Base.Axe"
                        result[fullId] = itemKey
                    end
                end
            end
        end
    end
    return result
end

-- map of _vanilla_ item full types to ItemKey, e.g. "Base.Axe" => ItemKey for Base.Axe
local baseItemKeys = gatherBaseItemKeys()

local function optional2str(opt)
    if opt and opt ~= EMPTY_OPTIONAL then
        return tostring(opt):gsub("Optional%[", ""):gsub("%]$", "")
    else
        return nil
    end
end

-- XXX don't use ItemKey.getByItemKeyValue() because it matches by substring: ItemKey.getByItemKeyValue("WoodAxeForged") => "Base.Axe"
-- ItemKey.new though OVERWRITES (!) the values in internal BY_NAME index
local function getBaseItemKey(camelCase)
    if type(camelCase) ~= "string" then logger:warn("getBaseItemKey: expected string, got %S", camelCase); return nil end
    if not luautils.stringStarts(camelCase, ITEMKEY_BASE_PREFIX) then return nil end

    local result = baseItemKeys[camelCase]
    if result then return result end

    -- non-vanilla item with "Base." prefix

    local item = getItem(camelCase)
    if item then return ItemKey.new(item:getName(), item:getItemType()) end

    local name   = camelCase:sub(#ITEMKEY_BASE_PREFIX + 1) -- "Base.Axe" -> "Axe"
    local optKey = ItemKey.getByName(name)                 -- Optional[Base.Axe], but Optional is not exposed to Lua :(
    if not optKey or optKey == EMPTY_OPTIONAL then return nil end

    item = getItem(optional2str(optKey))
    if item then return ItemKey.new(item:getName(), item:getItemType()) end

    logger:warn("getBaseItemKey: cannot resolve ItemKey for %S", camelCase)
    return nil
end

-- typeName may be:
--   "Base.ShotgunShells"
--   "MagneticRound"
--   "base:bullets_9mm"
local _cache = {}
local function findAmmoType(typeName)
    local cached = _cache[typeName]
    if cached then return cached end

    local registry = Registries.AMMO_TYPE
    local result   = nil
    local regClass = nil
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

        result, regClass = ZModUnbork.RegCache.find(registry, underscore)
        if result then break end

        -- XXX Ammotype != Registries.AMMO_TYPE
        local id = optional2str(AmmoType.getByItemKey(camelCase)) -- AmmoType.getByItemKey("Base.Bullets9mm") => Optional[base:bullets_9mm] => "base:bullets_9mm"
        if id then
            result = registry:get(ResourceLocation.of(id))
            if result then break end
        end

        local registerArgs     = { camelCase }
        local registerBaseArgs = nil

        local baseItemKey = getBaseItemKey(camelCase)
        if baseItemKey then
            registerBaseArgs = { baseItemKey }
        else
            registerBaseArgs = false -- don't call registerBase() if ItemKey cannot be resolved => it will create the item in 'ZModUnbork' namespace
        end

        result = ZModUnbork.RegCache.create(registry, underscore, registerArgs, registerBaseArgs, regClass)
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
        ZModUnbork.clog("ItemType", "change itemType from %-*s to %-*s for %s", _maxTypeLen, curType, _maxTypeLen, newType, item:getFullName())
    else
        ZModUnbork.clog("ItemType", "set itemType to %-*s for %s", _maxTypeLen, newType, item:getFullName())
    end
    item:setItemType(newType)

    -- weapons   are ItemType.WEAPON
    -- magazines are ItemType.NORMAL
    -- both of them have ammoType
    if scriptTbl.ammotype and item.getAmmoType and not item:getAmmoType() then
        local ammoType = findAmmoType(scriptTbl.ammotype)
        if ammoType then
            _maxTypeLen = math.max(_maxTypeLen, string.len(tostring(ammoType)))
            item:setAmmoType(ammoType)
            ZModUnbork.clog('AmmoType', "set ammoType to %-*s for %s", _maxTypeLen, ammoType, item:getFullName())
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
                    ZModUnbork.clog('LearnedRecipes', "set LearnedRecipes to %S for %s", scriptTbl.teachedrecipes, item:getFullName())
                    item:DoParam("LearnedRecipes", scriptTbl.teachedrecipes)
                end
            end
        end
    end
end

Events.OnGameBoot.Add(patchItemTypes)
