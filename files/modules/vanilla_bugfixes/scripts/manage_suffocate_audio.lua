local entity_id = GetUpdatedEntityID()
local dmc = EntityGetFirstComponent(entity_id, "DamageModelComponent")
if not dmc then return end

if not ComponentGetValue2(dmc, "mAirDoWeHave") then
    local tag = "sound_suffocating"
    if ComponentGetValue2(dmc, "mAirAreWeInWater") then
        tag = "sound_underwater"
    end

    GameEntityPlaySoundLoop(entity_id, tag, 1-(ComponentGetValue2(dmc, "air_in_lungs")/ComponentGetValue2(dmc, "air_in_lungs_max")))
end