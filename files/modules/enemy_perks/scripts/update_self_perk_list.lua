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
end

if perks then
	ComponentSetValue2(GetUpdatedComponentID(), "script_pressure_plate_change", perks)
end