local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local dir = utils.module_dir.."enemy_perks/"

local on_hit_callbacks = {
	{
		id = "curser",
		script_on_hit = dir.."scripts/curser_apply.lua",
		script_on_shot = function(projectile, x, y)
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
		end,
	}
}

local on_hit_callbacks_index = {}
for _,callback in ipairs(on_hit_callbacks) do
	on_hit_callbacks_index[callback.id] = callback
end

return {
	callbacks = on_hit_callbacks,
	callbacks_index = on_hit_callbacks_index,
}