---@diagnostic disable: undefined-global
local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

local aura = GetUpdatedEntityID()
local owner = EntityGetRootEntity( aura )
local x, y = EntityGetTransform( aura )

local INNER_RADIUS_INIT = ( utils.GetInternalInt( owner, "boss_cage_aura_inner_radius_init" ) or 375 ) * 0.5

local nearby_players = EntityGetInRadiusWithTag( x, y, INNER_RADIUS_INIT, "player_unit" )
if nearby_players and #nearby_players > 0 then
	EntityKill( aura )
	EntityAddChild( owner, EntityLoad( "mods/noita.hardmod/files/modules/vanilla_bosses/entity/boss_cage_aura_active.xml", x, y ) )

	local px, py = EntityGetTransform( nearby_players[1] )
	GamePlaySound( "data/audio/Desktop/event_cues.bank", "event_cues/rune/create", px, py )
end
