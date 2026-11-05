local damage_types_can_resist = {"projectile","electricity","explosion","fire","melee","drill","slice","ice","radioactive","curse","holy"}

function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
    local possession_limit_data = dofile_once("mods/noita.hardmod/files/modules/phantom_nemesis/files/scripts/possession_limits.lua")
    local possession_limit_per_biome = possession_limit_data.possession_limit_per_biome
    local possession_limit_default = possession_limit_data.default_biome_limit
    local entity_id = GetUpdatedEntityID()
    local pos_x,pos_y = EntityGetTransform(entity_id)
    local currbiome = BiomeMapGetName( pos_x, pos_y )
    local total_banishments_in_current_biome = tonumber(GlobalsGetValue(table.concat({"felcesis_",currbiome,"_count"}),"0"))
    local total_deaths = tonumber(GlobalsGetValue("felcesis_total_deaths","0"))
    total_banishments_in_current_biome = total_banishments_in_current_biome + 1
    total_deaths = total_deaths + 1
    GlobalsSetValue(table.concat({"felcesis_",currbiome,"_count"}),tostring(total_banishments_in_current_biome))
    GlobalsSetValue("felcesis_last_death",tostring(GameGetFrameNum()))
    GlobalsSetValue("felcesis_total_deaths",tostring(total_deaths))
    GamePlaySound( "mods/noita.hardmod/files/modules/phantom_nemesis/files/audio/phantom_audio.bank", "felcesis/phantom_banish", pos_x, pos_y )
    GamePrint(GameTextGet("$hardmod_phantom_banished",GameTextGetTranslatedOrNot("$hardmod_phantom_phantom_name")))

    -- Print the permanent banishment hint if Felcesis has been banished enough times to no longer be able to spawn in the current biome
    for _,biome in ipairs(possession_limit_per_biome) do
        if biome.id == currbiome then
            if total_banishments_in_current_biome >= biome.limit then
                return
                GamePrint(GameTextGet("$hardmod_phantom_banished_permanent",GameTextGetTranslatedOrNot("$hardmod_phantom_phantom_name")))
            end
        end
    end
    --Couldn't find our biome in the biome list, so it's probably a modded or undecided biome; default to a maximum possession count of 4
    if total_banishments_in_current_biome >= possession_limit_default then
        GamePrint(GameTextGet("$hardmod_phantom_banished_permanent",GameTextGetTranslatedOrNot("$hardmod_phantom_phantom_name")))
        return
    end
end

function damage_received( damage, message, entity_thats_responsible, is_fatal, projectile_thats_responsible )
    if message == "$damage_kick" then message = "$damage_melee" end
    message = message:gsub("^%$damage_", "")
    for k=1,#damage_types_can_resist do
        if damage_types_can_resist[k] == message then
            local damage_taken = tonumber(GlobalsGetValue(table.concat({"felcesis_damage_taken_from_",damage_types_can_resist[k],}),"0"))
            GlobalsSetValue(table.concat({"felcesis_damage_taken_from_",damage_types_can_resist[k],}),tostring(damage_taken+damage))
        end
    end
end