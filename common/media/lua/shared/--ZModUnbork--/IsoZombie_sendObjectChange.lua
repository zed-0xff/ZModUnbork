-- mods unborked:
--   ZomLootB42.3630270617

zdk.hook({
    [IsoZombie.class] = {
        sendObjectChange = function(orig, self, ...)
            local args = {...}
            if #args == 1 and type(args[1]) == "string" then
                ZModUnbork.log_once("IsoZombie.sendObjectChange('%s') - ignore", args[1])
                return
            end
            return orig(self, ...)
        end,
    }
})
