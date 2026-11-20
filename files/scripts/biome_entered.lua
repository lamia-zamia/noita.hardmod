old_biome_file = old_biome_file or nil

function biome_entered(name)
	local player = GetUpdatedEntityID()
	if not IsPlayer(player) then return end

	local x, y = EntityGetTransform(player)
	local file = DebugBiomeMapGetFilename(x, y)

	if file == old_biome_file then return end

	GlobalsSetValue("hardmod_player_new_biome_name", tostring(name))
	GameAddFlagRun("hardmod_player_biome_changed")
	old_biome_file = file
end
