local hooks = {}

hooks.mod_post_init = function()
	ModLuaFileAppend( "data/scripts/gun/gun.lua", "mods/noita.hardmod/files/modules/alt_fire_anything/scripts/gun_append.lua" )

	-- add guaranteed AFA spawns in orb rooms
	ModLuaFileAppend( "data/scripts/biomes/orbrooms/orbroom_05.lua", "mods/noita.hardmod/files/modules/alt_fire_anything/scripts/biomes/orbroom_append.lua" )
	ModLuaFileAppend( "data/scripts/biomes/orbrooms/orbroom_06.lua", "mods/noita.hardmod/files/modules/alt_fire_anything/scripts/biomes/orbroom_append.lua" )
	ModLuaFileAppend( "data/scripts/biomes/orbrooms/orbroom_10.lua", "mods/noita.hardmod/files/modules/alt_fire_anything/scripts/biomes/orbroom_append.lua" )
end

return hooks --Don't forget to do this if you want your changes to apply!!!!