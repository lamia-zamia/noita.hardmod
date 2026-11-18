--local biome_index = dofile_once("mods/noita.hardmod/lib/biome_index.lua") ---@type biome_path_to_simple_id
local enemy_perks = dofile_once("mods/noita.hardmod/files/modules/enemy_perks/enemy_perks_list.lua")
local eperk_utils = dofile_once("mods/noita.hardmod/files/modules/enemy_perks/eperk_utilities.lua")(enemy_perks) ---@type eperk_utils


function death(damage_type_bit_field, message, attacker, drop_items)
	local entity_id = GetUpdatedEntityID()

	for _,child in ipairs(EntityGetAllChildren(entity_id) or {}) do
		if EntityGetName(child) == "hardmod.enemy_perks" then
			for _,varcomp in ipairs(EntityGetComponent(child, "VariableStorageComponent") or {}) do
				if ComponentGetValue2(varcomp, "name") == "enemy_perk_data" then
					local x,y = EntityGetTransform(entity_id)
					local death_data = {
						entity_id = entity_id,
						x = x, y = y,
						damage_type_bit_field = damage_type_bit_field,
						message = message,
						attacker = attacker,
						drop_items = drop_items,
					}
					eperk_utils.handle_perk_on_death(ComponentGetValue2(varcomp, "value_string"), death_data)
					break
				end
			end
			break
		end
	end
end
