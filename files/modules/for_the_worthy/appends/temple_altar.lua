local orig_spawn_all_perks = spawn_all_perks

function spawn_all_perks(x, y, ...)
	orig_spawn_all_perks(x, y, ...)

	if not GameHasFlagRun("hardmod_hell") then return end

	local biome_index = dofile_once("mods/noita.hardmod/lib/biome_index.lua")---@type biome_path_to_simple_id
	local biome_below = biome_index[DebugBiomeMapGetFilename(x, y + 512)]

	if biome_below == "hiisi_base" and GlobalsGetValue("TEMPLE_SPAWN_GUARDIAN") ~= "1" then
		GamePrintImportant("$logdesc_temple_spawn_guardian", "$hardmod_hell_mode_god_force_anger")
		GlobalsSetValue("TEMPLE_SPAWN_GUARDIAN", "1")
		GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/angered_the_gods/create", x, y)
		GameScreenshake(150)

		temple_spawn_guardian(x + 30, y - 30)
	end
end
