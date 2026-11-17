local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

local aura = GetUpdatedEntityID()
local owner = EntityGetRootEntity( aura )

local INNER_RADIUS_INIT = ( utils.GetInternalInt( owner, "boss_cage_aura_inner_radius_init" ) or 375 ) * 0.5

local shield = EntityGetFirstComponent( aura, "EnergyShieldComponent" )
local shield_inner = EntityGetFirstComponent( aura, "ParticleEmitterComponent", "shield_inner" )
local shield_ring = EntityGetFirstComponent( aura, "ParticleEmitterComponent", "shield_ring" )
local shield_hit = EntityGetFirstComponent( aura, "ParticleEmitterComponent", "shield_hit" )

ComponentSetValue2( shield, "radius", INNER_RADIUS_INIT )
ComponentSetValue2( shield_inner, "area_circle_radius", 1, INNER_RADIUS_INIT )
ComponentSetValue2( shield_ring, "area_circle_radius", INNER_RADIUS_INIT, INNER_RADIUS_INIT )
ComponentSetValue2( shield_hit, "area_circle_radius", INNER_RADIUS_INIT, INNER_RADIUS_INIT )
