function shot(projectile)
	local x,y = EntityGetTransform(projectile)
	EntityAddChild(projectile, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/curser_hit.xml", x, y))

	local comp = EntityAddComponent2(projectile, "ParticleEmitterComponent", {
		emitted_material_name = "spark_red",
		count_min = 0,
		count_max = 2,
		x_pos_offset_min = -4,
		x_pos_offset_max = -2,
		y_pos_offset_min = -2,
		y_pos_offset_max = 4,
		x_vel_min = -10,
		x_vel_max = 10,
		y_vel_min = -10,
		y_vel_max = 10,
		lifetime_min = 1.1,
		lifetime_max = 2.8,
		create_real_particles = false,
		emit_cosmetic_particles = true,
		emission_interval_min_frames = 1,
		emission_interval_max_frames = 1,
		delay_frames = 2,
		is_emitting = true,
	})
	--We can't set these values inherently when creating a new component via lua, so set them here instead
	ComponentSetValue2(comp, "offset", -1, 0)

	EntityAddComponent2(projectile, "LuaComponent", {
		script_source_file = "mods/noita.hardmod/files/modules/enemy_perks/scripts/curser_projectile_explode.lua",
		execute_every_n_frame = -1,
		execute_on_removed = true,
	})
end
