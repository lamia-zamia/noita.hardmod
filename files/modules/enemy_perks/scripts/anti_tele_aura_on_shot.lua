dofile_once( "data/scripts/lib/utilities.lua" )
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local RADIUS = 220

-- ty Lamia
function shot( entity_id )
	local x, y = EntityGetTransform( entity_id )
	local aura = EntityGetClosestWithTag( x, y, "hardmod_anti_tele_aura" )
	if not aura then return end
	local ax, ay = EntityGetTransform( aura )

	if get_distance( x, y, ax, ay ) < RADIUS then
		local delete_proj = false

	    --Grabs a list of all TeleportProjectileComponents and disables them
	    local comps = EntityGetComponentIncludingDisabled(entity_id,"TeleportProjectileComponent")
	    if comps then
	        for k=1,#comps
	        do local v = comps[k]
	            EntityRemoveComponent(entity_id,v)
	            local delete_proj = true
	        end
	    end

	    --Grabs a list of all Swapper Components and disables them
	    local comps = EntityGetComponentIncludingDisabled(entity_id,"HitEffectComponent")
	    if comps then
	        for k=1,#comps
	        do local v = comps[k]
	            if ComponentGetValue2(v,"effect_hit") == "SWAPPER" then
	                EntityRemoveComponent(entity_id,v)
	            	local delete_proj = true
	            end
	        end
	    end

	    --Disables RGB Portals from teleporting you
	    EntitySetComponentsWithTagEnabled(entity_id,"apotheosis_blob_boss",false)

	    if delete_proj then
	    	EntityKill( entity_id )
	    end
	end
end
