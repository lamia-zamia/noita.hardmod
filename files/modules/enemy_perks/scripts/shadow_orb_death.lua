local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

function death(damage_type_bit_field, message, attacker, drop_items)
	local entity_id = GetUpdatedEntityID()
	local pos_x, pos_y = EntityGetTransform(entity_id)

	local how_many = 8.0
	local speed = 500
	local angle = math.random(0, 3.13159)
	local angle_inc = 3.1415926535 * 2 / how_many

	for i=1,how_many do
		local vel_x = math.cos(angle) * speed
		local vel_y = 0 - math.sin(angle) * speed
		utils.ShootProjectile(entity_id, "data/entities/projectiles/darkflame.xml", pos_x, pos_y, vel_x, vel_y)

		angle = angle + angle_inc
	end

	GamePlaySound("data/audio/Desktop/animals.bank", "animals/failed_alchemist_b_orb/explode", pos_x, pos_y)



	local perks
	for _,varcomp in ipairs(EntityGetComponent(entity_id, "VariableStorageComponent") or {}) do
		if ComponentGetValue2(varcomp, "name") == "hardmod_stored_perks" then
			perks = ComponentGetValue2(varcomp, "value_string")
			break
		end
	end
	if not perks then return end

	local biome_index = dofile_once("mods/noita.hardmod/lib/biome_index.lua") ---@type biome_path_to_simple_id
	local enemy_perks = dofile_once("mods/noita.hardmod/files/modules/enemy_perks/enemy_perks_list.lua")
	local eperk_utils = dofile_once("mods/noita.hardmod/files/modules/enemy_perks/eperk_utilities.lua")(enemy_perks) ---@type eperk_utils

	local x,y = EntityGetTransform(entity_id)
	local death_data = {
		entity_id = entity_id,
		x = x, y = y,
		damage_type_bit_field = damage_type_bit_field,
		message = message,
		attacker = attacker,
		drop_items = drop_items,
	}

	eperk_utils.handle_perk_on_death(perks, death_data)
end