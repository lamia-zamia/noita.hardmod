local callback_data = dofile_once("mods/noita.hardmod/files/modules/enemy_perks/procedural/data.lua")

function shot(projectile)
	local x, y = EntityGetTransform(projectile)
	EntityAddChild(projectile, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/generated/%ID%_shot.xml", x, y))

	local callback = callback_data.callbacks_index["%ID%"]
	if callback.script_on_shot then
		callback.script_on_shot(projectile, x, y)
	end
	if callback.entity_on_shot then
		EntityLoadToEntity(projectile, callback.entity_on_shot)
	end

	EntityAddComponent2(projectile, "LuaComponent", {
		script_source_file = "mods/noita.hardmod/files/modules/enemy_perks/generated/%ID%_explode.lua",
		execute_every_n_frame = -1,
		execute_on_removed = true,
	})
end
