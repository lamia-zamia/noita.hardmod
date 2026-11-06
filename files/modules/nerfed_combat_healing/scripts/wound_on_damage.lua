function damage_received( damage, desc, entity_who_caused, is_fatal )
    local entity_id = GetUpdatedEntityID()
    local comp_id = GetUpdatedComponentID()
    local wound_duration_per_percentage_lost = 2 --Time in seconds
    local maximum_duration_per_instance = 10 --Maximum duration of wounded in seconds that can be gained from a single instance of damage. (ie if the player takes 50% of their health as damage they should gain 100 seconds of wounded, but this would cap it at 10 seconds)
    local wound_duration_cap = 20 --Upper limit in seconds that the wounded status gained from taking damage can be

    if ComponentGetIsEnabled( comp_id ) == false then
        return
    end
    local healthcomp = EntityGetFirstComponentIncludingDisabled(entity_id,"DamageModelComponent")
    local hp_max = ComponentGetValue2(healthcomp,"max_hp")
    local hp_min = hp_max * 0.01 --1% hp damage = 2s of wounded
    local wounded_time = math.min(maximum_duration_per_instance,math.floor(damage / hp_min) * wound_duration_per_percentage_lost)
    if wounded_time > 0 then
        local children = EntityGetAllChildren(entity_id) or {}
        local found = false
        for k=1,#children do
            if EntityGetName(children[k]) == "apotheosis_wounded" and ComponentGetValue2(EntityGetFirstComponentIncludingDisabled(children[k],"UIIconComponent"),"icon_sprite_file") == "mods/noita.hardmod/files/modules/nerfed_combat_healing/ui_gfx/status_indicators/nohealing_hardmod.png" then --This scan feels so stupid but it saves a tag I guess..? Maybe wounded should just be an entity tag at this point.. but for just one status effect..? ugh...
                found = true
                local comp = EntityGetFirstComponentIncludingDisabled(children[k],"GameEffectComponent")
                ComponentSetValue2(comp,"frames",math.min(wound_duration_cap * 60,ComponentGetValue2(comp,"frames") + (wounded_time* 60)))
                break
            end
        end
        if found == false then
            local child = EntityLoad("mods/noita.hardmod/files/modules/nerfed_combat_healing/entities/hitfx_nohealing_variable.xml",0,0)
            EntityAddComponent2(
                child,
                "GameEffectComponent",
                {
                    effect = "NONE",
                    frames = 60 * wounded_time
                }
		    )
            EntityAddChild(entity_id,child)
        end
    end
end