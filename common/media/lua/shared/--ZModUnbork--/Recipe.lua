-- mods revived:
--   LeGourmetRevolution.2719327441 (B41)
--   RebalancedYieldsButchering.3564838872
--   Support Corps.3512993822

if Recipe then
    if type(Recipe) ~= "table" then return end
else
    Recipe = {}
end

local keys = {"GetItemTypes", "OnCreate", "OnTest", "OnGiveXP"}
for _, key in ipairs(keys) do
    if not Recipe[key] then
        Recipe[key] = {}
    end
end
