---@diagnostic disable: undefined-global
local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

local aura = GetUpdatedEntityID()
local owner = EntityGetRootEntity( aura )
local x, y = EntityGetTransform( aura )

local FRAMES_BEFORE_MAX = utils.GetInternalInt( owner, "boss_cage_aura_frames_before_max" ) or 3600
local INNER_RADIUS_INIT = utils.GetInternalInt( owner, "boss_cage_aura_inner_radius_init" ) or 375
local INNER_RADIUS_SHRINK = utils.GetInternalInt( owner, "boss_cage_aura_inner_radius_shrink" ) or 250
local OUTER_RADIUS = utils.GetInternalInt( owner, "boss_cage_aura_outer_radius" ) or 500

local inner_ring = EntityGetFirstComponent( aura, "ParticleEmitterComponent", "inner_ring" )
local rays_outward = EntityGetFirstComponent( aura, "ParticleEmitterComponent", "rays_outward" )
local rock_curse = EntityGetFirstComponent( aura, "ParticleEmitterComponent", "rock_curse" )
-- local rays_inward = EntityGetFirstComponent( aura, "ParticleEmitterComponent", "rays_inward" )
-- local outer_ring = EntityGetFirstComponent( aura, "ParticleEmitterComponent", "outer_ring" )
if not inner_ring or not rays_outward or not rock_curse then return end

local frames_alive = GameGetFrameNum() - ( utils.GetInternalInt( aura, "spawn_frame" ) or 0 )

local inner_radius = INNER_RADIUS_INIT - INNER_RADIUS_SHRINK
if frames_alive < FRAMES_BEFORE_MAX then
	inner_radius = INNER_RADIUS_INIT - ( ( INNER_RADIUS_SHRINK / FRAMES_BEFORE_MAX ) * frames_alive )

	ComponentSetValue2( inner_ring, "area_circle_radius", inner_radius, inner_radius )
	ComponentSetValue2( rays_outward, "area_circle_radius", inner_radius, inner_radius + 25 )
	ComponentSetValue2( rock_curse, "area_circle_radius", inner_radius, OUTER_RADIUS )
end

local nearby_players = EntityGetWithTag( "player_unit" )
if nearby_players then
	for i,player in ipairs( nearby_players ) do
		dofile_once( "data/scripts/lib/utilities.lua" )
		local px, py = EntityGetTransform( player )
		local dist = get_distance( x, y, px, py )
		if dist > inner_radius then
			local dmg_comp = EntityGetFirstComponentIncludingDisabled( player, "DamageModelComponent" )
			if dmg_comp then
				local p_hp = ComponentGetValue2( dmg_comp, "hp" )
				local p_max_hp = ComponentGetValue2( dmg_comp, "max_hp" )

				if dist > OUTER_RADIUS then
					EntityInflictDamage( player, p_hp * 0.5, "DAMAGE_SLICE", "divine tether", "NONE", 0, 0 )

					-- revert aura to dormant state
					EntityKill( aura )
					EntityAddChild( owner,
						EntityLoad( "mods/noita.hardmod/files/modules/vanilla_bosses/entity/boss_cage_aura_dormant.xml", x, y ) )

					GamePlaySound( "data/audio/Desktop/player.bank", "player_projectiles/megalaser/launch", px, py )

					local owner_dmg_comp = EntityGetFirstComponentIncludingDisabled( owner, "DamageModelComponent" )
					if owner_dmg_comp then
						local o_max_hp = ComponentGetValue2( owner_dmg_comp, "max_hp" )
						ComponentSetValue2( owner_dmg_comp, "hp", o_max_hp )
					end
				else
					EntityInflictDamage( player, 0.00667, "DAMAGE_CURSE", "divine tether", "NONE", 0, 0 )
				end
			end
		end
	end
end

