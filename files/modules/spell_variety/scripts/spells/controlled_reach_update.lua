dofile_once( "data/scripts/lib/utilities.lua" )
local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

local function distance_between( entity_a, entity_b )
	local ax, ay = EntityGetTransform( entity_a )
	local bx, by = EntityGetTransform( entity_b )

	return get_distance( ax, ay, bx, by )
end

local proj_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponentIncludingDisabled( proj_id, "ProjectileComponent" )
if proj_comp then
	local owner_id = ComponentGetValue2( proj_comp, "mWhoShot" )

	local dist = distance_between( owner_id, proj_id )
	local max_dist = utils.GetInternalInt( proj_id, "controlled_reach_max_dist" )
	if owner_id and max_dist > 0 and dist > max_dist then
		EntityKill( proj_id )
	end
end
