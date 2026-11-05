local hooks = {}
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

hooks.mod_post_init = function()
	ModLuaFileAppend(
		"data/scripts/biomes/temple_altar.lua",
		"mods/noita.hardmod/files/modules/trial_perks/scripts/biomes/temple_altar_append.lua" )
end

hooks.player_spawned = function( player, is_run_start )
	if is_run_start then
		EntityAddComponent2( player, "LuaComponent", {
			script_source_file = "mods/noita.hardmod/files/modules/trial_perks/scripts/player/trial_perk_scan.lua",
			execute_every_n_frame = 60,
		})
	end
end

return hooks --Don't forget to do this if you want your changes to apply!!!!
