local biome_modifiers_patch_init_lua_version = 1
if BIOME_MODIFIERS_PATCH_INIT_LUA_VERSION and BIOME_MODIFIERS_PATCH_INIT_LUA_VERSION >= biome_modifiers_patch_init_lua_version then return end
BIOME_MODIFIERS_PATCH_INIT_LUA_VERSION = biome_modifiers_patch_init_lua_version

function OnBiomeConfigLoaded()
	dofile("data/scripts/biome_modifiers.lua")
	init_biome_modifiers()
end
