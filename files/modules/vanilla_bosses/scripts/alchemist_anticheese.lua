function damage_about_to_be_received(damage, x, y, dealt_by, crit)
	local comp = EntityGetFirstComponent(GetUpdatedEntityID(), "HitboxComponent")
	if (comp and ComponentGetValue2(comp, "damage_multiplier") <= 0.01) or dealt_by == GetUpdatedEntityID() then
		return 0, 0
	end

	return damage, crit
end

