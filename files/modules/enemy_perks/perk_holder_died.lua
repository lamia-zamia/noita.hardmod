function death(damage_type_bit_field, message, attacker, drop_items)
	local entity_id = GetUpdatedEntityID()
	local attacker_was_player = EntityHasTag(attacker, "player_unit") or EntityHasTag(attacker, "polymorphed_player")

	for _,child in ipairs(EntityGetAllChildren(entity_id) or {}) do
		if EntityGetName(child) == "hardmod.enemy_perks" then
			for _,varcomp in ipairs(EntityGetComponent(child, "VariableStorageComponent") or {}) do
				if ComponentGetValue2(varcomp, "name") == "enemy_perk_data" then
					local new_perk_discovered
					local held_perks = {}
					local how_many_of_each_perk = {}
					for perk_id in ComponentGetValue2(varcomp, "value_string"):gmatch("([^,]+)") do
						how_many_of_each_perk[perk_id] = (perk_id[perk_id] or 0) + 1
						held_perks[#held_perks+1] = perk_id
						if attacker_was_player then
							local persistent_flag_name = "perk_picked_enemyperk_"..perk_id:lower()
							if not HasFlagPersistent(persistent_flag_name) then
								new_perk_discovered = true
								AddFlagPersistent(persistent_flag_name)
								GameAddFlagRun("new_"..persistent_flag_name)
							end
						end
					end
					if new_perk_discovered then GameAddFlagRun("hardmod_new_enemy_perk_discovered") end

					local x, y = EntityGetTransform(entity_id)
					local death_data = {
						x = x, y = y,
						attacker_was_player = false,
						damage_type_bit_field = damage_type_bit_field,
						message = message,
						attacker = attacker,
						drop_items = drop_items,
						held_perks = held_perks,
						how_many_of_each_perk = how_many_of_each_perk,
					}
					SetRandomSeed(5932+y, x-135)
					for _,perk in ipairs(dofile_once("mods/noita.hardmod/files/modules/enemy_perks/enemy_perks_list.lua")) do
						if perk.on_death and how_many_of_each_perk[perk.id] then
							for _=1,how_many_of_each_perk[perk.id] do
								perk:on_death(entity_id, death_data)
							end
						end
					end
					break
				end
			end
			break
		end
	end
end
