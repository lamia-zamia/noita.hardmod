local entity_id = GetUpdatedEntityID()
local x,y = EntityGetTransform(entity_id)

if 0 == (#EntityGetInRadiusWithTag(x, y, 60, "player_unit") + #EntityGetInRadiusWithTag(x, y, 60, "polymorphed_player")) then
	local outer_density = 2 * math.pi * 60
	local pec = EntityAddComponent2(entity_id, "ParticleEmitterComponent", {
		emitted_material_name = "spark_red",
		count_min = outer_density,
		count_max = outer_density,
		lifetime_min = 1,
		lifetime_max = 5,
		render_on_grid = true,
		airflow_force = 0.3,
		airflow_time = 0.01,
		airflow_scale = 0.05,
		emit_cosmetic_particles = true,
		emission_interval_min_frames = 0,
		emission_interval_max_frames = 0,
	})
	ComponentSetValue2(pec, "area_circle_radius", 60, 60)
	ComponentSetValue2(pec, "gravity", 0, 0)

	EntityAddComponent2(entity_id, "LifetimeComponent", {
		lifetime = 3
	})

	GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/rune/destroy", x, y)
end