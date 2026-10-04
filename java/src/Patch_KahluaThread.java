package me.zed_0xff.z_mod_unbork;

import me.zed_0xff.zombie_buddy.annotations.Patch;
import me.zed_0xff.zombie_buddy.Logger;

import se.krka.kahlua.j2se.KahluaTableImpl;
import zombie.Lua.LuaManager;

public class Patch_KahluaThread {
    @Patch(className = "se.krka.kahlua.vm.KahluaThread", methodName = "tableget")
    public static class Patch_tableget {
        @Patch.OnExit
        public static void exit(Object table, Object key, @Patch.Return(readOnly = false) Object result) {
            if (result != null) return;
            if (!(key instanceof String skey)) return;
            if ("controllerTest".equals(skey)) return;
            if (!(table instanceof KahluaTableImpl tbl)) return;
            if (table == LuaManager.env) return;

            Object type = tbl.rawget("Type");
            if (type != null) return;

            var mt = tbl.getMetatable();
            if (mt == null) return;

            if (mt.rawget("__nullSubkeysAsTables") == null) return;

            var logger = Logger.get("ZModUnbork");
            logger.info("tableget", mt, tbl, key, result);
        }
    }
}
