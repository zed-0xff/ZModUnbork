-- mods revived:
--   LeGourmetRevolution.2719327441 (B41)
--   RebalancedYieldsButchering.3564838872
--   Support Corps.3512993822

if type(Recipe) ~= "table" then return end

if not Recipe.OnCreate then Recipe.OnCreate = {} end
if not Recipe.OnTest   then Recipe.OnTest   = {} end
if not Recipe.OnGiveXP then Recipe.OnGiveXP = {} end
