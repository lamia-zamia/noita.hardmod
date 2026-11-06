
function shot(entity_id)
	local proj_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ProjectileComponent")
	if proj_comp ~= nil then
		ComponentObjectSetValue2(proj_comp, "damage_by_type", "fire", 0.4)
	end
	local x, y = EntityGetTransform(entity_id)
	EntityAddChild(entity_id, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/pyrelord_hitfx.xml", x, y))

	local comp = EntityAddComponent2(entity_id, "ParticleEmitterComponent", {
		emitted_material_name = "fire",
		count_min = 6,
		count_max = 8,
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
		create_real_particles = true,
		emit_cosmetic_particles = false,
		emission_interval_min_frames = 1,
		emission_interval_max_frames = 1,
		delay_frames = 2,
		is_emitting = true,
	})
	--We can't set these values inherently when creating a new component via lua, so set them here instead
	ComponentSetValue2(comp, "offset", -1, 0)
end
