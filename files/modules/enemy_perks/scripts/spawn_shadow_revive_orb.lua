local entity_id = GetUpdatedEntityID()

function death(damage_type_bit_field, message, attacker, drop_items)
	local perks = ComponentGetValue2(GetUpdatedComponentID(), "script_pressure_plate_change")

	--for _,child in ipairs(EntityGetAllChildren(entity_id) or {}) do
	--	if EntityGetName(child) == "hardmod.enemy_perks" then
	--		for _,varcomp in ipairs(EntityGetComponent(child, "VariableStorageComponent") or {}) do
	--			if ComponentGetValue2(varcomp, "name") == "enemy_perk_data" then
	--				perks = ComponentGetValue2(varcomp, "value_string")
	--				break
	--			end
	--		end
	--		break
	--	end
	--end --prior code that would calculate, but EntityGetAllChildren appears to return nil on repeat

	print(perks)
	print("checking...")
	if not perks then print("fail") return end
	print("passed!")

	local x,y = EntityGetTransform(entity_id) --also nil on repeat
	print(("%s, %s"):format(x, y))
	local orb_for_pondering = EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/shadow_revive_orb.xml", x, y)

	EntitySetName(orb_for_pondering, EntityGetFilename(entity_id))
	EntityAddComponent2(orb_for_pondering, "VariableStorageComponent", {
		name = "hardmod_stored_perks",
		value_string = perks
	})
end