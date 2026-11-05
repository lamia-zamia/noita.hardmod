local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local portal_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( portal_id )

local player = EntityGetInRadiusWithTag( x, y, 15, "player_unit" )[1]
if player ~= nil then
	local tx = utils.GetInternalInt( player, "hardmod_return_portal_dest_x" )
	local ty = utils.GetInternalInt( player, "hardmod_return_portal_dest_y" )
	if tx == nil or tx == 0 then
		tx = 766
		ty = -808
	end

	-- "teleport"
	GamePlaySound( "data/audio/Desktop/misc.bank", "misc/teleport_use_end", tx, ty )
	EntitySetTransform( player, tx, ty )
	EntityLoad( "mods/noita.hardmod/files/modules/trial_perks/gfx/spells/blink_tele_particles.xml", x, y )
	EntityLoad( "mods/noita.hardmod/files/modules/trial_perks/gfx/spells/blink_tele_particles.xml", tx, ty )
	GamePrint( "Teleported!" )
	EntityKill( portal_id )
end
