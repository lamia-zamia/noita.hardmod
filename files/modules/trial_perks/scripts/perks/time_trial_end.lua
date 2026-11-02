dofile_once( "mods/noita.hardmod/files/modules/trial_perks/scripts/trial_perk_utils.lua" )
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local player = EntityGetRootEntity( GetUpdatedEntityID() )
if ( utils.GetInternalInt( player, "hardmod_time_trial_start_y" ) or 0 ) == 0 then return end
utils.SetInternalInt( player, "hardmod_time_trail_start_y", 0 )

GamePrintImportant( "$hardmod_perk_time_trial_msg_fail" )
utils.EntityRemoveAllByTag( player, "hardmod_time_trial" )
SwapPerkIconForSpent( player, "$hardmod_perk_time_trial_name", false )
utils.SetInternalInt( player, "hardmod_time_trial_start_y", 0 )

local x, y = EntityGetTransform( player )
GamePlaySound( "data/audio/Desktop/animals.bank", "animals/sheep/confused", x, y )
