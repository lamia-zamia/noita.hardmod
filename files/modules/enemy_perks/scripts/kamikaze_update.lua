
local owner = GetUpdatedEntityID()
local x, y = EntityGetTransform( owner )

-- check if a player is nearby for kamikaze
local nearby_players = EntityGetInRadiusWithTag( x, y, 16, "player_unit" )
if nearby_players == nil or #nearby_players == 0 then return end

local dmg_comp = EntityGetFirstComponentIncludingDisabled( owner, "DamageModelComponent" )
if dmg_comp then
	local hp = ComponentGetValue2( dmg_comp, "hp" )
	local expl_mtp = ComponentObjectGetValue2( dmg_comp, "damage_multipliers", "explosion" )

	-- only trigger kamikaze explosion if the owner has low enough HP to die from it
	if ( hp * expl_mtp ) < 5 then -- bomb deals 5 (i.e. 125) damage
		EntityLoad( "mods/noita.hardmod/files/modules/enemy_perks/entities/kamikaze_explosion.xml", x, y )
	end
end
