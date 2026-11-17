---@diagnostic disable: undefined-global
local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

function damage_received( damage, desc, entity_who_caused, is_fatal )
	local boss = GetUpdatedEntityID()
	if EntityGetAllChildren( boss, "hardmod_boss_cage" )[1] ~= nil then return end
	local x, y = EntityGetTransform( boss )

	local dmg_comp = EntityGetFirstComponentIncludingDisabled( boss, "DamageModelComponent" )
	if dmg_comp then
		local boss_hp = ComponentGetValue2( dmg_comp, "hp" )
		local boss_max_hp = ComponentGetValue2( dmg_comp, "max_hp" )

		if damage > 0 and EntityHasTag( entity_who_caused, "player_unit" ) then
			utils.SetInternalInt( boss, "boss_cage_aura_frames_before_max", 3600 )
			utils.SetInternalInt( boss, "boss_cage_aura_inner_radius_init", 375 )
			utils.SetInternalInt( boss, "boss_cage_aura_inner_radius_shrink", 225 )
			EntityAddChild( boss, EntityLoad( "mods/noita.hardmod/files/modules/vanilla_bosses/entity/boss_cage_aura_active.xml", x, y ) )

			local nearby_players = EntityGetWithTag( "player_unit" )
			if nearby_players and #nearby_players > 0 then
				local px, py = EntityGetTransform( nearby_players[1] )
				GamePlaySound( "data/audio/Desktop/event_cues.bank", "event_cues/rune/create", px, py )
			end
		end
	end
end
