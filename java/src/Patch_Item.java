package me.zed_0xff.z_mod_unbork;

import me.zed_0xff.zombie_buddy.annotations.Patch;
import me.zed_0xff.zombie_buddy.Logger;

import java.util.HashMap;

import zombie.scripting.objects.EvolvedRecipe;
import zombie.scripting.objects.Item;
import zombie.scripting.objects.ItemRecipe;
import zombie.scripting.ScriptManager;

public class Patch_Item {
    @Patch(className = "zombie.scripting.objects.Item", methodName = "OnScriptsLoaded")
    public static class Patch_OnScriptsLoaded {
        @Patch.OnEnter
        public static void enter(@Patch.This Item self, @Patch.Field HashMap<String, ItemRecipe> itemRecipeMap) {
            var logger = Logger.get("ZModUnbork");
            var evolvedRecipes = ScriptManager.instance.getAllEvolvedRecipesList();

            itemRecipeMap.entrySet().removeIf(entry -> {
                EvolvedRecipe recipe = ScriptManager.instance.getEvolvedRecipe(entry.getKey());
                if (recipe != null) {
                    return false;
                }
                for (EvolvedRecipe r : evolvedRecipes) {
                    if (r.template.equalsIgnoreCase(entry.getKey())) {
                        return false;
                    }
                }

                logger.warn("removing item recipe", entry.getKey(), "from", self);
                return true;
            });
        }
    }
}
