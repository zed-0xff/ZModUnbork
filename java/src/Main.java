package me.zed_0xff.z_mod_unbork;

import me.zed_0xff.zombie_buddy.Exposer;

public class Main {
    public static void main(String[] args) {
        Exposer.exposeMethod("zombie.inventory.types.MapItem", "getSymbols");
    }
}
