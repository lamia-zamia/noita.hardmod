local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" )

function MultiplyProjDmg( proj_id, mtp, mtp_source_name )
    local existing_mtp_sources = utils.GetInternalString( proj_id, "hardmod_proj_dmg_mtp_sources" ) or ""

    if not string.find( existing_mtp_sources, mtp_source_name ) then
        utils.SetInternalString( proj_id, "hardmod_proj_dmg_mtp_sources", existing_mtp_sources .. mtp_source_name .. "," )

        local proj_comp = EntityGetFirstComponent( proj_id, "ProjectileComponent" )
        if proj_comp then
            local old_dmg = ComponentGetValue2( proj_comp, "damage" )
            ComponentSetValue2( proj_comp, "damage", old_dmg * mtp )

            local old_expl_dmg = ComponentObjectGetValue2( proj_comp, "config_explosion", "damage" )
            if old_expl_dmg ~= nil then
                ComponentObjectSetValue2( proj_comp, "config_explosion", "damage", old_expl_dmg * mtp )
            end

            -- TODO: do this for the other damage types as well
            local damage_types = { "melee", "projectile", "explosion", "electricity", "fire", "drill", "slice", "ice", "healing", "physics_hit", "radioactive", "poison", "curse", "holy" }
            for i,dmg_type in ipairs( damage_types ) do
                local old_dmg = ComponentObjectGetValue2( proj_comp, "damage_by_type", dmg_type )
                if old_dmg ~= nil then
                    ComponentObjectSetValue2( proj_comp, "damage_by_type", dmg_type, old_dmg * mtp )
                end
            end
        end
    end
end

local proj_id = GetUpdatedEntityID()

-- quadruple the projectile's damage, including modifiers
MultiplyProjDmg( proj_id, 4.0, "echo_shot" )

-- change the projectile sprite
local sprite_comp = EntityGetFirstComponentIncludingDisabled( proj_id, "SpriteComponent" )
if sprite_comp ~= nil then
	ComponentSetValue2( sprite_comp, "image_file", "mods/noita.hardmod/files/modules/spell_variety/gfx/spells/echo_shot_red.xml" )
end

-- change the explosion sprite
local proj_comp = EntityGetFirstComponentIncludingDisabled( proj_id, "ProjectileComponent" )
if proj_comp ~= nil then
	-- also make the projectile more destructive
	local expl_radius = ComponentObjectGetValue2( proj_comp, "config_explosion", "explosion_radius" )
	ComponentObjectSetValue2( proj_comp, "config_explosion", "explosion_radius", expl_radius + 3 )
	local prev_mdtd = ComponentObjectGetValue2( proj_comp, "config_explosion", "max_durability_to_destroy" )
	ComponentObjectSetValue2( proj_comp, "config_explosion", "max_durability_to_destroy", prev_mdtd + 2 )

	if expl_radius + 3 > 8 then
		ComponentObjectSetValue2( proj_comp, "config_explosion", "explosion_sprite",
		"mods/noita.hardmod/files/modules/spell_variety/gfx/spells/explosion_032_red.xml" )
	else
		ComponentObjectSetValue2( proj_comp, "config_explosion", "explosion_sprite",
		"mods/noita.hardmod/files/modules/spell_variety/gfx/spells/explosion_016_red.xml" )
	end
end

-- change the particle colors
local particle_comps = EntityGetComponentIncludingDisabled( proj_id, "ParticleEmitterComponent" )
if exists( particle_comps ) then
	for i,particle_comp in ipairs( particle_comps ) do
		ComponentSetValue2( particle_comp, "emitted_material_name", "spark_red_bright" )
	end
end

-- play a small explosion in the original colour to better communicate the transition
local x, y = EntityGetTransform( proj_id )
EntityLoad( "mods/noita.hardmod/files/modules/spell_variety/entities/spells/echo_shot_fake_explosion.xml", x, y )
