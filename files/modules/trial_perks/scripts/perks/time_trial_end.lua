dofile_once("mods/noita.hardmod/files/modules/trial_perks/scripts/trial_perk_utils.lua")
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

-- measure to make polymorph not end the trial
local polyd_player = EntityGetWithTag("polymorphed_player")
if polyd_player and #polyd_player > 0 then
	return
end

local player = EntityGetRootEntity(GetUpdatedEntityID())
if tonumber(GlobalsGetValue("hardmod_time_trial_start_y")) or 0 == 0 then return end

GamePrintImportant("$hardmod_perk_time_trial_msg_fail")
utils.EntityRemoveAllByTag(player, "hardmod_time_trial")
SwapPerkIconForSpent(player, "$hardmod_perk_time_trial_name", false)
GlobalsSetValue("hardmod_time_trial_start_y", "0")

local x, y = EntityGetTransform(player)
GamePlaySound("data/audio/Desktop/animals.bank", "animals/sheep/confused", x, y)
