dofile_once( "mods/noita.hardmod/files/modules/trial_perks/scripts/trial_perk_utils.lua" )
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
dofile_once( "data/scripts/lib/utilities.lua" )

local x, y = EntityGetTransform( GetUpdatedEntityID() )

local owner = EntityGetClosestWithTag( x, y, "player_unit" )
if owner == nil then return end

local p_dcomp = EntityGetFirstComponentIncludingDisabled( owner, "DamageModelComponent" )
if not p_dcomp then return end
local p_hp = ComponentGetValue2( p_dcomp, "hp" )
local p_max_hp = ComponentGetValue2( p_dcomp, "max_hp" )

for i,proj_id in ipairs( EntityGetInRadiusWithTag( x, y, 20, "projectile" ) ) do
	local proj_comp = EntityGetFirstComponentIncludingDisabled( proj_id, "ProjectileComponent" )
	if not proj_comp then goto continue end
	local proj_source = ComponentGetValue2( proj_comp, "mWhoShot" )

	-- only heal the player if the projectile isn't theirs
	if proj_source ~= owner then

		-- determine heal ratio based on the projectile's velocity
		local proj_velocity = ComponentGetValue2( proj_comp, "speed_min" ) -- default value, just in case
	    local vcomp = EntityGetFirstComponentIncludingDisabled( proj_id, "VelocityComponent" )
	    if vcomp ~= nil then
	        local vx, vy = ComponentGetValue2( vcomp, "mVelocity" )
	        proj_velocity = get_magnitude( vx, vy )
	    end
		local heal_ratio = utils.Remap( proj_velocity, 100, 1000, 0.5, 1.0 )

		-- heal the player
		local proj_dmg = ComponentGetValue2( proj_comp, "damage" )
		local proj_x, proj_y = EntityGetTransform( proj_id )
	    ComponentSetValue2( p_dcomp, "hp", math.min( p_hp + ( proj_dmg * heal_ratio ), p_max_hp ) )
	    GamePlaySound( "data/audio/Desktop/projectiles.bank", "projectiles/glowing_laser/destroy", proj_x, proj_y )
		EntityLoad( "mods/noita.hardmod/files/modules/trial_perks/entities/spells/parry_heal.xml", proj_x, proj_y )

		-- return the projectile to caster
		local sx, sy = EntityGetTransform( proj_source )
    	GameShootProjectile( owner, x, y, sx, sy, proj_id )
	end

    -- "disable" the projectile's explosion
	ComponentObjectSetValue2( proj_comp, "config_explosion", "explosion_radius", 0 )
    ComponentObjectSetValue2( proj_comp, "config_explosion", "create_cell_probability", 0 )
    ComponentObjectSetValue2( proj_comp, "config_explosion", "damage", 0 )
    ComponentObjectSetValue2( proj_comp, "config_explosion", "damage_mortals", 0 )
	::continue::
end
