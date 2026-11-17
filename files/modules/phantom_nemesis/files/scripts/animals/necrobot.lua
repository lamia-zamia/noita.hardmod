local child_id = GetUpdatedEntityID()
local entity_id = EntityGetParent(child_id)
local x, y = EntityGetTransform( entity_id )
local radius = 70

local targets = EntityGetInRadiusWithTag( x, y, radius, "mortal" )
local found = false
EntityAddTag(entity_id,"necrobot_NOT")

for i,v in ipairs( targets ) do
	if ( EntityHasTag( v, "player_unit" ) == false ) and ( EntityHasTag( v, "necrobot_NOT" ) == false ) then
		local file = EntityGetFilename( v )

		if ( file ~= nil ) and ( #file > 0 ) and ( string.find( file, "entities/animals/" ) ~= nil ) then
			EntityAddComponent2(v, "LuaComponent", {
				script_death = "data/scripts/status_effects/necrobot.lua",
				execute_every_n_frame = -1,
			})

			local eid = EntityLoad( "data/entities/particles/tinyspark_green_sparse.xml", x, y )
			EntityAddChild( v, eid )
		end

		EntityAddTag( v, "necrobot_NOT" )
		break
	end
end
