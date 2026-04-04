-- mods revived:
--   Support Corps.3512993822
--   RebalancedYieldsButchering.3564838872

if type(Recipe) ~= "table" then return end

if not Recipe.OnCreate then
    Recipe.OnCreate = {}
end

if not Recipe.OnTest then
    Recipe.OnTest = {}
end
