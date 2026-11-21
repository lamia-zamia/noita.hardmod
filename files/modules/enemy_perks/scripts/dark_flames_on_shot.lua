
function shot(entity_id)
	local is_darkflame = EntityHasTag(entity_id, "hardmod_darkflame")
	if not is_darkflame then
		EntityAddComponent2(entity_id, "LuaComponent", {
			script_source_file = "data/scripts/projectiles/darkflame.lua",
			execute_every_n_frame = 1,
		})
	end
end
