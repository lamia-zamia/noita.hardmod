
local x, y = EntityGetTransform( GetUpdatedEntityID() )

local nearby_mortals = EntityGetInRadiusWithTag( x, y, 32, "mortal" )
if nearby_mortals then
	for i,mortal in ipairs( nearby_mortals ) do

		-- check if the target is wounded
		local is_wounded = false
		local children = EntityGetAllChildren(target)
		if children then
			for k=1,#children
			do v = children[k]
				if EntityGetName(v) == "apotheosis_wounded" then
					is_wounded = true
				end
			end
		end

		if not is_wounded then
			local dmg_comp = EntityGetFirstComponentIncludingDisabled( mortal, "DamageModelComponent" )
			if dmg_comp ~= nil then
				local p_hp = ComponentGetValue2( dmg_comp, "hp" )
				local p_max_hp = ComponentGetValue2( dmg_comp, "max_hp" )
				ComponentSetValue2( dmg_comp, "hp", math.min( p_hp + 0.12, p_max_hp ) ) -- 3 hp per tick, 12 per second, 30 max

				GamePlaySound( "data/audio/Desktop/misc.bank", "game_effect/regeneration/tick", x, y )
			end
		end
	end
end
