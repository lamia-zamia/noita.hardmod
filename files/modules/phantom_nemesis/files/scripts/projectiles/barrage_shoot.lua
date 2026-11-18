function shot(entity_id)
    EntityAddComponent2(entity_id, "LuaComponent", {
		script_source_file="mods/noita.hardmod/files/modules/phantom_nemesis/files/scripts/projectiles/larpa_shotgun.lua",
		execute_every_n_frame=1,
		remove_after_executed=true
	})
end
