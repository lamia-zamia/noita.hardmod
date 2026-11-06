function death(damage_type_bit_field, message, attacker, drop_items)
	local entity_id = GetUpdatedEntityID()

	local perks
	for _,child in ipairs(EntityGetAllChildren(entity_id) or {}) do
		if EntityGetName(child) == "hardmod.enemy_perks" then
			for _,varcomp in ipairs(EntityGetComponent(child, "VariableStorageComponent") or {}) do
				if ComponentGetValue2(varcomp, "name") == "enemy_perk_data" then
					perks = ComponentGetValue2(varcomp, "value_string")
					break
				end
			end
			break
		end
	end --prior code that would calculate, but EntityGetAllChildren appears to return nil on repeat

	if not perks then return end

	local x,y = EntityGetTransform(entity_id) --also nil on repeat
	local orb_for_pondering = EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/shadow_revive_orb.xml", x, y)

	EntitySetName(orb_for_pondering, EntityGetFilename(entity_id))
	EntityAddComponent2(orb_for_pondering, "VariableStorageComponent", {
		name = "hardmod_stored_perks",
		value_string = perks
	})
end