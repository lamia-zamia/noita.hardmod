
function damage_received( damage, desc, entity_who_caused, is_fatal )
    if #EntityGetWithTag( "hardmod_rewind_marker" ) == 0 then return end
    if entity_who_caused == nil then return end

    local player = GetUpdatedEntityID()
    local x, y = EntityGetTransform( player )

	local marker_id = EntityGetClosestWithTag( x, y, "hardmod_rewind_marker" )
	if marker_id ~= nil then
		local tx, ty = EntityGetTransform( marker_id )
		EntitySetTransform( player, tx, ty )
		GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/teleport/destroy", tx, ty )
		EntityKill( marker_id )

	    local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" )
		utils.SetInternalInt( player, "hardmod_teleportitis_last_tele_frame", GameGetFrameNum() )
	end
end
