local hooks = {}
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

MinibossCreator = dofile_once("mods/noita.hardmod/files/modules/phantom_nemesis/files/scripts/miniboss_creator.lua")
local possession_limit_data = dofile_once("mods/noita.hardmod/files/modules/phantom_nemesis/files/scripts/possession_limits.lua")
local possession_limit_per_biome = possession_limit_data.possession_limit_per_biome
local possession_limit_default = possession_limit_data.default_biome_limit
local last_seen_biome = ""
local biome_entered_frame = 0

hooks.mod_pre_init = function()
	ModRegisterAudioEventMappings("mods/noita.hardmod/files/modules/phantom_nemesis/files/audio/GUIDs.txt")
end

hooks.post_update = function ()
    local current_frame = GameGetFrameNum()
    if current_frame % 60 ~= 0 then return end --Don't need to spam globals calls every frame, once per second is good enough
    local last_felcesis_possession_attempt = tonumber(GlobalsGetValue("felcesis_last_possession","0")) --1 minute grace period (when combined with the cooldown) when starting a new run before felcesis can appear
    local biomes_visited = tonumber(GlobalsGetValue("felcesis_biomes_visited","0"))
    local biomes_needed_to_remove_limit = 999 --20 -- Originally this was 20, so if you visited 20 biomes then there'd be no more banishment limit before felcesis stops pursuing you in a specific biome, but it might feel better to play without this
    local felcesis_summon_pursuit_cooldown = 60 * 60 -- 60 second cooldown between possession attempts while felcesis is pursuing the player
    local felcesis_summon_death_cooldown = 60 * (120 + (biomes_visited * 30)) -- 120 second cooldown between possession attempts after felcesis is slain (+30 seconds for each biome visited as to not make felecsis annoying)
    local felcesis_summon_lastdeath_time = tostring(GlobalsGetValue("felcesis_last_death","0"))

    local cam_x,cam_y = GameGetCameraBounds()
    local currbiome = BiomeMapGetName( cam_x, cam_y )

    local minimum_time_inside_biome = 1800 --Safeguard against entering a biome for second then leaving still incrementing Ira's power level, this means the player must be inside a biome for at least 30 seconds for Ira to increment their power level because the player entered it.
    if currbiome ~= last_seen_biome then
        last_seen_biome = currbiome
        biome_entered_frame = current_frame
    end

    local last_frame_entered_new_biome = tonumber(GlobalsGetValue("felceis_last_biome_frame","0"))
    local entered_new_biome_graceperiod = 60 * 45 --45 second safeguard against Ira when entering a new biome
    GlobalsSetValue("felcesis_last_biome",currbiome)
    local flag = table.concat({"felcesis_",currbiome,"_visited"})
    local total_banishments_in_current_biome = tonumber(GlobalsGetValue(table.concat({"felcesis_",currbiome,"_count"}),"0"))
    local biome_weight = 1

    if biomes_visited >= biomes_needed_to_remove_limit then goto finishlimitcheck end
    for _,biome in ipairs(possession_limit_per_biome) do
        for _,biome_id in ipairs(biome.ids) do
            if biome_id == currbiome then
                biome_weight = biome.weight or 1
                if total_banishments_in_current_biome >= biome.limit and biome.limit >= 0 then
                    return
                else
                    goto finishlimitcheck
                end
            end
        end
    end
    --Couldn't find our biome in the biome list, so it's probably a modded or undecided biome; default to a maximum possession count of 4
    if total_banishments_in_current_biome >= possession_limit_default then
        return
    end
    ::finishlimitcheck::

    if (current_frame - biome_entered_frame) >= minimum_time_inside_biome and GameHasFlagRun(flag) == false then
        GameAddFlagRun( flag )
        GlobalsSetValue("felceis_last_biome_frame",tostring(current_frame))
        last_frame_entered_new_biome = current_frame
        GlobalsSetValue("felcesis_biomes_visited",tostring(biomes_visited + biome_weight)) --Increment the phantom's biome power
    end

    --GamePrint(table.concat({current_frame,", ",last_felcesis_possession_attempt,", ",felcesis_summon_cooldown}))

    if current_frame > felcesis_summon_lastdeath_time + felcesis_summon_death_cooldown and current_frame > last_felcesis_possession_attempt + felcesis_summon_pursuit_cooldown and current_frame > last_frame_entered_new_biome + entered_new_biome_graceperiod then
        local found, id, targ_x, targ_y = MinibossCreator.FindPossessionTarget(biomes_visited)
        if found then
            local miniboss_stats = MinibossCreator.CalculateMinibossPower(biomes_visited)
            MinibossCreator.CreateMiniboss(id, targ_x, targ_y,miniboss_stats.tier,miniboss_stats.budget,miniboss_stats.hp_mult)
            GlobalsSetValue("felcesis_last_possession",tostring(current_frame))
            local player_id = EntityGetWithTag("player_unit")[1] or 0
            if player_id > 0 then
                local plyr_x,plyr_y = EntityGetTransform(player_id)
                GamePlaySound( "mods/noita.hardmod/files/modules/phantom_nemesis/files/audio/phantom_audio.bank", "felcesis/phantom_possess", plyr_x, plyr_y )

                if GameHasFlagRun("felcesis_haunting_started") == false then
                    GamePlaySound( "mods/noita.hardmod/files/modules/phantom_nemesis/files/audio/phantom_audio.bank", "felcesis/phantom_summon", plyr_x, plyr_y )
                    GameAddFlagRun("felcesis_haunting_started")
                end
            end
            --Summon audio
            GamePlaySound( "mods/noita.hardmod/files/modules/phantom_nemesis/files/audio/phantom_audio.bank", "felcesis/phantom_possess", targ_x, targ_y )
        end
    end
end

return hooks --Don't forget to do this if you want your changes to apply!!!!