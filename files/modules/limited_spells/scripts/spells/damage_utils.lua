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
