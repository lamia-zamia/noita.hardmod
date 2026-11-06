local last_frame = -100000

function GetShieldRadius(entity_id)
	local hitbox_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "HitboxComponent") or 0
	if hitbox_comp == 0 then return 18 end
	local vars_to_check = {"aabb_min_x","aabb_max_x","aabb_min_y","aabb_max_y"}
	local furthest_hitbox_point = 0
	local padding = 10
	for _,var in ipairs(vars_to_check) do
		local hitbox_length = math.abs(ComponentGetValue2(hitbox_comp,var))
		if hitbox_length > furthest_hitbox_point then
			furthest_hitbox_point = hitbox_length
		end
	end
	return furthest_hitbox_point + padding
end

function damage_received( damage, desc, entity_who_caused, is_fatal )
	local entity_id    = GetUpdatedEntityID()
	local pos_x, pos_y = EntityGetTransform( entity_id )
	local frame = GameGetFrameNum()
	local vcomp = 0
	local shield_cooldown = 720 --12 second cooldown between shields

	local colour
	local comps = EntityGetComponent(entity_id,"VariableStorageComponent")
	for k=1,#comps
	do comp = comps[k]
		if ComponentGetValue2(comp,"name") == "shield_colour" then
			vcomp = comp
			colour = ComponentGetValue2(comp,"value_string")
			last_frame = ComponentGetValue2(comp,"value_int")
		end
	end

	if ( entity_who_caused == entity_id ) or (frame <= last_frame + shield_cooldown) then return end

	local children = EntityGetAllChildren(entity_id)
	for k=1,#children
	do v = children[k]
		if EntityGetName(v) == "corrupted_shield" then
			EntityKill(v)
			break
		end
	end
	
	local shield_radius_default = 18
	local shield_radius = GetShieldRadius(entity_id)
	local shield_id = EntityLoad( "mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/misc/shield_reactive_shield.xml", pos_x, pos_y )
	EntityAddChild( entity_id, shield_id )

	local shield_comp = EntityGetFirstComponentIncludingDisabled(shield_id,"EnergyShieldComponent")
	ComponentSetValue2(shield_comp,"radius",shield_radius)
	local particle_comps = EntityGetComponentIncludingDisabled(shield_id,"ParticleEmitterComponent") or {}
	for _,particle_comp in ipairs(particle_comps) do
		local particle_comp_min_size,_ = ComponentGetValue2(particle_comp,"area_circle_radius")
		if particle_comp_min_size > 0 then particle_comp_min_size = shield_radius end
		ComponentSetValue2(particle_comp,"area_circle_radius",particle_comp_min_size,shield_radius)
	end
	local sprite_comp = EntityGetFirstComponentIncludingDisabled(shield_id,"SpriteComponent")
	local scale = shield_radius/shield_radius_default
	ComponentSetValue2(sprite_comp,"special_scale_x",scale)
	ComponentSetValue2(sprite_comp,"special_scale_y",scale)

	ComponentSetValue2(vcomp,"value_int",GameGetFrameNum())
end
