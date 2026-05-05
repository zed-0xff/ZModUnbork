if not PZAPI or not PZAPI.ModOptions then return end
local Config = ZModUnbork.Config

local options = PZAPI.ModOptions:create(ZModUnbork.MOD_ID, ZModUnbork.MOD_DISPLAY_NAME)
local config = {
    verbose_logs = options:addTickBox(
        "verbose_logs",
        "Verbose item logs",
        false,
        "Log each change."
    ),

    log_stats = options:addTickBox(
        "log_stats",
        "Log stats",
        true
    ),
}

options.apply = function(self)
    for key, element in pairs(config) do
        local value = element:getValue()
        Config.set(key, value)
    end
end
