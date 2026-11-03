dofile_once( "mods/noita.hardmod/files/modules/trial_perks/scripts/trial_perk_utils.lua" )
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local x, y = EntityGetTransform( GetUpdatedEntityID() )

local spawn_return_portal = false
local nearby_players = EntityGetInRadiusWithTag( x, y, 100, "player_unit" )
if nearby_players then
	for i,player in ipairs( nearby_players ) do

		-- check for Glass Heart
		local start_y = utils.GetInternalInt( player, "hardmod_glass_heart_start_y" ) or 0
		if start_y ~= 0 and ( y - start_y ) > 600 then
			utils.SetInternalInt( player, "hardmod_glass_heart_start_y", 0 )

			utils.EntityRemoveAllByTag( player, "hardmod_glass_heart" )
			local dmg_comp = EntityGetFirstComponentIncludingDisabled( player, "DamageModelComponent" )
			if dmg_comp then
				local p_hp = ComponentGetValue2( dmg_comp, "hp" )
				local p_max_hp = ComponentGetValue2( dmg_comp, "max_hp" )
				ComponentSetValue2( dmg_comp, "max_hp", p_max_hp * 2 )

				utils.TriggerScriptDelayed( player, "mods/noita.hardmod/files/modules/trial_perks/scripts/perks/glass_heart_reward.lua", 5 )
				spawn_return_portal = true
			end
		end

		-- check for Time Trial
		start_y = utils.GetInternalInt( player, "hardmod_time_trial_start_y" ) or 0
		if start_y ~= 0 and ( y - start_y ) > 600 then
			utils.SetInternalInt( player, "hardmod_time_trial_start_y", 0 )

			utils.TriggerScriptDelayed( player, "mods/noita.hardmod/files/modules/trial_perks/scripts/perks/time_trial_reward.lua", 5 )
			spawn_return_portal = true
		end
	end
end

if spawn_return_portal then
	local portal = EntityLoad( "mods/noita.hardmod/files/modules/ring_of_returning/entities/return_portal.xml", x - 70, y - 20 )
	if portal ~= nil then
		local tele_comp = EntityGetFirstComponentIncludingDisabled( portal, "TeleportComponent" )
		if tele_comp ~= nil then
			local tx, ty = 766, -808

			local players = EntityGetWithTag( "player_unit" )
			if players ~= nil then
				for i,player in ipairs( players ) do
					local stored_x = utils.GetInternalInt( player, "hardmod_return_portal_dest_x" )
					local stored_y = utils.GetInternalInt( player, "hardmod_return_portal_dest_y" )
					if stored_x ~= nil and stored_y ~= nil then
						tx = stored_x
						ty = stored_y
						break
					end
				end
				
				ComponentSetValue2( tele_comp, "target", tx, ty )
			end
		end
	end
end
