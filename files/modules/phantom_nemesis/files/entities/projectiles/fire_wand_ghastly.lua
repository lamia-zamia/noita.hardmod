dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/gun/gun.lua")
local speed = 400

local entity_id = GetUpdatedEntityID()
local pos_x, pos_y, rot = EntityGetTransform( entity_id )
local wand_vsc_comp = EntityGetFirstComponentIncludingDisabled(entity_id,"VariableStorageComponent") or 0
local phantom_tier = ComponentGetValue2(wand_vsc_comp,"value_float")
local proj_filepath = phantom_tier >= 5 and "mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/projectiles/fire_wand_ghastly_projectile.xml" or "mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/projectiles/fire_wand_ghastly_projectile_nomodifiers.xml"

-- velocity
local vel_x,vel_y = GameGetVelocityCompVelocity(entity_id)
vel_x, vel_y = vec_normalize(vel_x, vel_y)
if vel_x == nil then return end
vel_x = vel_x * speed
vel_y = vel_y * speed

local count = 1

SetRandomSeed( pos_x * vel_x, pos_y * vel_y )

for i=1,count do
	local px = pos_x + vel_x * 0.1
	local py = pos_y + vel_y * 0.1
	local proj_id = shoot_projectile_from_projectile( entity_id, proj_filepath, px + Random( -5, 5 ), py + Random( -5, 5 ), vel_x, vel_y )
	local damage = (2 * phantom_tier)
	local proj_comp = EntityGetFirstComponentIncludingDisabled(proj_id,"ProjectileComponent")
	ComponentObjectSetValue(proj_comp,"config_explosion","damage",damage)
	ComponentObjectSetValue(proj_comp,"damage_by_type","fire",damage-1)
end

-- sound is played here instead of the projectiles to avoid duplicates
GamePlaySound( "data/audio/Desktop/projectiles.bank", "projectiles/enlightened_laser/launch_fire", pos_x, pos_y )

