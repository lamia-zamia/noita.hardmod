
function shot(entity_id)
	local proj_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ProjectileComponent")
	if proj_comp then
		ComponentSetValue2(proj_comp, "friendly_fire", false)
		ComponentSetValue2(proj_comp, "explosion_dont_damage_shooter", true)
	end
end
