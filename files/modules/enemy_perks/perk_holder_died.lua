function death(damage_type_bit_field, message, attacker, drop_items)
	if EntityHasTag(entity_thats_responsible, "player_unit") or EntityHasTag(entity_thats_responsible, "polymorphed_player") then
		for _,child in ipairs(EntityGetAllChildren(GetUpdatedEntityID()) or {}) do
			if EntityGetName(child) == "hardmod.enemy_perks" then
				for _,varcomp in ipairs(EntityGetComponent(child, "VariableStorageComponent") or {}) do
					if ComponentGetValue2(varcomp, "name") == "enemy_perk_data" then
						local new_perk_discovered
						for perk_id in ComponentGetValue2(varcomp, "value_string"):gmatch("([^,]+)") do
							local persistent_flag_name = "perk_picked_enemyperk_"..perk_id:lower()
							if not HasFlagPersistent(persistent_flag_name) then
								new_perk_discovered = true
								AddFlagPersistent(persistent_flag_name)
								GameAddFlagRun("new_"..persistent_flag_name)
							end
						end
						if new_perk_discovered then GameAddFlagRun("hardmod_new_enemy_perk_discovered") end
						break
					end
				end
				break
			end
		end
	end
end