
function shot(entity_id)
	local proj_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ProjectileComponent")
	if proj_comp then
		ComponentSetValue2(proj_comp, "collide_with_world", false)
		ComponentSetValue2(proj_comp, "penetrate_world", true)
	end
end
