local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

function damage_received(damage, message, attacker, is_fatal)
	local entity_id = GetUpdatedEntityID()

	-- if heartbreak is active, lose max HP equal to 50% of damage taken
	local heartbreak_state = utils.GetInternalInt(entity_id, "hardmod_heartbreak_enabled")
	if heartbreak_state ~= nil and heartbreak_state == 1 then
		local dmg_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "DamageModelComponent")
		if dmg_comp ~= nil then
			local p_max_hp = ComponentGetValue2(dmg_comp, "max_hp")

			ComponentSetValue2(dmg_comp, "max_hp", math.min(math.max(p_max_hp - (damage * 0.1), 0.04)), p_max_hp)
		end
	end
end