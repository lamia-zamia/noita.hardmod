local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

function damage_received( damage, desc, entity_who_caused, is_fatal )
    local owner = GetUpdatedEntityID()
    local ally = utils.GetInternalInt( owner, "hardmod_soul_linked_ally" ) or 0
    if ally == 0 then return end

	---@diagnostic disable-next-line: cast-type-mismatch
	---@cast ally entity_id

    local dmg_comp_self = EntityGetFirstComponentIncludingDisabled( owner, "DamageModelComponent" )
    local dmg_comp_ally = EntityGetFirstComponentIncludingDisabled( ally, "DamageModelComponent" )
    if dmg_comp_self and dmg_comp_ally then
        local hp_self = ComponentGetValue2( dmg_comp_self, "hp" )
        local hp_ally = ComponentGetValue2( dmg_comp_ally, "hp" )

        if damage > hp_self and ( math.abs( hp_ally - hp_self ) > 0.004 ) then
            ComponentSetValue2( dmg_comp_self, "hp", 0.04 )
            GamePrint( "hp is now: " .. ComponentGetValue2( dmg_comp_self, "hp" ) )

            if ( utils.GetInternalInt( owner, "hardmod_soul_linked_immunity_given" ) or 0 ) == 0 then
                utils.SetInternalInt( owner, "hardmod_soul_linked_immunity_given", 1 )
                LoadGameEffectEntityTo( owner, "mods/noita.hardmod/files/modules/enemy_perks/entities/soul_linked_protection.xml" )
            end
        -- if both enemies have <1(.25) hp, they both die
        elseif hp_self <= 0.05 and hp_ally <= 0.05 then
            EntityInflictDamage( ally, hp_ally * 1.1, "DAMAGE_CURSE", "soul linked", "NORMAL", 0, 0 )
        end
    end
end

function damage_about_to_be_received( damage, x, y, entity_thats_responsible, critical_hit_chance )
    local owner = GetUpdatedEntityID()
    local ally = utils.GetInternalInt( owner, "hardmod_soul_linked_ally" ) or 0

    if ally > 0 then
		---@diagnostic disable-next-line: cast-type-mismatch
		---@cast ally entity_id

        local dmg_comp_self = EntityGetFirstComponentIncludingDisabled( owner, "DamageModelComponent" )
        local dmg_comp_ally = EntityGetFirstComponentIncludingDisabled( ally, "DamageModelComponent" )
        if dmg_comp_self and dmg_comp_ally then
            local hp_self = ComponentGetValue2( dmg_comp_self, "hp" )
            local hp_ally = ComponentGetValue2( dmg_comp_ally, "hp" )

            -- if the owner would die from the damage and its ally has more than 1 hp remaining, prevent death
            GamePrint( "hp self: " .. hp_self .. " / hp ally: " .. hp_ally )
            if damage > hp_self and hp_ally > 0.04 then
                if ( utils.GetInternalInt( owner, "hardmod_soul_linked_immunity_given" ) or 0 ) == 0 then
                    utils.SetInternalInt( owner, "hardmod_soul_linked_immunity_given", 1 )

                    -- local x, y = EntityGetTransform( owner )
                    -- local particles = EntityLoad( "mods/noita.hardmod/files/modules/enemy_perks/entities/soul_linked_shield.xml", x, y )
                    -- EntityAddChild( owner, particles )
                    LoadGameEffectEntityTo( owner, "mods/noita.hardmod/files/modules/enemy_perks/entities/soul_linked_protection.xml" )
                end

                return hp_self - 0.04, critical_hit_chance
            -- if both enemies have 1 HP, they both die
            elseif hp_self <= 0.04 and hp_ally <= 0.04 then
                EntityInflictDamage( ally, hp_ally * 1.1, "DAMAGE_CURSE", "soul linked", "NORMAL", 0, 0 )
            end
        end
    end

    return damage, critical_hit_chance
end
