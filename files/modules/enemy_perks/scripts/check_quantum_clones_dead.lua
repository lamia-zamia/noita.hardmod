local root = EntityGetRootEntity(GetUpdatedEntityID())
local component = GetUpdatedComponentID()

local shared_clone_id = ComponentGetValue2(component, "limit_how_many_times_per_frame")
local target_clone_num = ComponentGetValue2(component, "limit_to_every_n_frame")

local members = {root}
for _,enemy in ipairs(EntityGetWithTag("hardmod_blessed")) do
	if enemy == root then goto check_next_enemy end

	for _,child in ipairs(EntityGetAllChildren(enemy) or {}) do
		if EntityGetName(child) == "hardmod.eperk_enemy_clone_data" then
			for _,varcomp in ipairs(EntityGetComponent(child, "VariableStorageComponent") or {}) do
				if ComponentGetValue2(varcomp, "name") == "hardmod_quantum_clones_data" then
					if ComponentGetValue2(varcomp, "value_int") == shared_clone_id then members[#members+1] = enemy else end
					goto check_next_enemy
				end
			end
			::check_next_enemy::
		end
	end
	::check_next_enemy::
end

if #members ~= target_clone_num then
	for _,member in ipairs(members) do
		EntityKill(member)
	end
end

function death(damage_type_bit_field, message, attacker, drop_items)
	for _,member in ipairs(members) do
		EntityKill(member)
	end
end