-- mods unborked:
--   LeGourmetRevolution.2719327441 (B41)

-- 41.78: Animals
-- 42.12: TrapAnimals
if not Animals then
    -- TrapAnimals is not defined yet because it's in _server_/Traps/TrapDefinition.lua
    -- TrapDefinition.lua inits it as "TrapAnimals = TrapAnimals or {}", so it's safe to use it here
    -- but can't put this initializer into 'server/' bc LeGourmetRevolution's MTTrapDefinition.lua is loaded _before_ ANY other server file,
    -- bc LeGourmetRevolution overrides vanilla server/Map/MapObjects/MOTrap.lua, and requires MTTrapDefinition.lua in it
    TrapAnimals = TrapAnimals or {}
    Animals = TrapAnimals
end
