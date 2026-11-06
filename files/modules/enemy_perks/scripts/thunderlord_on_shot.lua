function shot( entity_id )
	local proj_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ProjectileComponent")
	if proj_comp ~= nil then
		ComponentObjectSetValue2(proj_comp, "damage_by_type", "electricity", 0.4)
	end
	local x, y = EntityGetTransform( entity_id )
	EntityAddChild(entity_id, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/thunderlord_hitfx.xml", x, y))

	EntityAddComponent2(entity_id, "LuaComponent", {
		script_source_file = "mods/noita.hardmod/files/modules/enemy_perks/scripts/thunderlord_try_electrify.lua",
		execute_times = 1,
		execute_every_n_frame = 1,
		remove_after_executed = true,
	})

	local comp = EntityAddComponent2(entity_id, "SpriteParticleEmitterComponent", {
		sprite_file = "data/particles/spark_electric.xml",
		delay = 0,
		lifetime = 0,
		velocity_slowdown = 0,
		rotation = 0,
		angular_velocity = 0,
		use_velocity_as_rotation = false,
		emission_interval_min_frames = 1,
		emission_interval_max_frames = 3,
		count_min = 1,
		count_max = 1,
	})
	--We can't set these values inherently when creating a new component via lua, so set them here instead
	ComponentSetValue2(comp, "color", 1, 1, 1, 1)
	ComponentSetValue2(comp, "color_change", 0, 0, 0, 0)
	ComponentSetValue2(comp, "velocity", 0, 0)
	ComponentSetValue2(comp, "gravity", 0, 10)
	ComponentSetValue2(comp, "scale", 1, 1)
	ComponentSetValue2(comp, "scale_velocity", 0, 0)
	ComponentSetValue2(comp, "randomize_rotation", -3.1415, 3.1415)
	ComponentSetValue2(comp, "randomize_position", -2, 2, -2, 2)
end
