-- mods unborked:
--   ArsenalGunFighter.2297098490 (B41)

zdk.augment_metatable( HandWeapon.class, {
    getCanon     = function(self) return self:getWeaponPart("Canon") end,
    getClip      = function(self) return self:getWeaponPart("Clip") end,
    getRecoilpad = function(self) return self:getWeaponPart("RecoilPad") end,
    getScope     = function(self) return self:getWeaponPart("Scope") end,
    getSling     = function(self) return self:getWeaponPart("Sling") end,
    getStock     = function(self) return self:getWeaponPart("Stock") end,
})
