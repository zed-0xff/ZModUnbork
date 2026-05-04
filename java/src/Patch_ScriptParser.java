package me.zed_0xff.z_mod_unbork;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

import me.zed_0xff.zombie_buddy.Logger;
import me.zed_0xff.zombie_buddy.Patch;

// mods unborked:
//   ArsenalGunFighter.2297098490 (B41)

@Patch(className = "zombie.scripting.ScriptParser", methodName = "stripComments")
public class Patch_ScriptParser {
    public static final Pattern PATTERN = Pattern.compile("(\\s*item\\s+[^\\s]+)\\s+--\\s.*");

    @Patch.OnExit
    public static void exit(String totalFile, @Patch.Return(readOnly = false) String result) {
        StringBuilder out = new StringBuilder();
        StringBuilder log = new StringBuilder();

        String[] lines = result.split("\\R");

        boolean was = false;
        for (String line : lines) {
            Matcher m = PATTERN.matcher(line);

            // full-line match, so no ^ or $ needed
            if (m.matches()) {
                String replaced = m.group(1);
                out.append(replaced);
                Logger.info("[ZModUnbork] ScriptParser.stripComments: replaced \"" + line.trim() + "\" with \"" + replaced.trim() + "\"");
                was = true;
            } else {
                out.append(line);
            }
            out.append(System.lineSeparator());
        }

        if (was) {
            result = out.toString();
        }
    }
}
