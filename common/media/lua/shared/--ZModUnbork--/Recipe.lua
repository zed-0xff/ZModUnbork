-- mods revived:
--   Support Corps.3512993822

if type(Recipe) == "table" and not Recipe.OnCreate then
    Recipe.OnCreate = {}
end
