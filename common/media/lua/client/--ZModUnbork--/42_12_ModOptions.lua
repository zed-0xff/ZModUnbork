-- mods unborked:
--   SnakeUtilsPack.2719327441 (B41)

-- SnakeUtilsPack.2719327441/media/lua/client/SUPConfig.lua creates options without storeCurrentValue/restoreOriginalValue, which causes
-- 	 java.lang.RuntimeException: Object tried to call nil in storeCurrentValues [nil method 'storeCurrentValue'] at KahluaUtil.fail(KahluaUtil.java:99).
local function fixModOptions()
    local options = zdk.dig("MainOptions.instance.gameOptions.options")
    if type(options) ~= "table" then return end

    for _, opt in ipairs(options) do
        if type(opt) == "table" then
            opt.storeCurrentValue    = opt.storeCurrentValue or function() end
            opt.restoreOriginalValue = opt.restoreOriginalValue or function() end
        end
    end
end
Events.OnMainMenuEnter.Add(fixModOptions)
