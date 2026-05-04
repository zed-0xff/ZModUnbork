package me.zed_0xff.z_mod_unbork;

import me.zed_0xff.zombie_buddy.Logger;
import me.zed_0xff.zombie_buddy.Patch;

import zombie.core.skinnedmodel.advancedanimation.AnimNode;

// mods unborked:
//   ArsenalGunFighter.2297098490 (B41)

// make NPE in AnimNode.Parse() not crash the game, but instead log the error and continue as if it returned null
// NPE caused by ArsenalGunFighter trying to override game default XMLs which have _slightly_ different format in 42.12+
@Patch(className = "zombie.core.skinnedmodel.advancedanimation.AnimNode", methodName = "Parse")
public class Patch_AnimNode {
    @Patch.OnExit(onThrowable = java.lang.NullPointerException.class)
    public static void exit(String source, @Patch.Thrown(readOnly = false) Throwable thrown) {
        if (thrown == null) return;

        Logger.info("[ZModUnbork] AnimNode.Parse(\"" + source + "\") => " + thrown);
        thrown = null;
    }
}
