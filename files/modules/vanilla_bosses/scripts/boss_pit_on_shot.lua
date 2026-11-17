
function shot( entity_id )
	local make_shot_phasing = false
	local spells = { "orb_poly", "orb_neutral", "orb_tele", "orb_dark" }
	for _,spell in ipairs( spells ) do
		if string.find( EntityGetFilename( entity_id ), spell ) then
			make_shot_phasing = true
			break
		end
	end

	if make_shot_phasing then
		local proj_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "ProjectileComponent" )
		if proj_comp then
			ComponentSetValue2( proj_comp, "collide_with_world", false )
			ComponentSetValue2( proj_comp, "penetrate_world", true )
			ComponentObjectSetValue2( proj_comp, "config_explosion", "max_durability_to_destroy", 15 )
		end
	end
end
