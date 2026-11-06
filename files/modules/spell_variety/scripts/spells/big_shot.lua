local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
dofile_once( "mods/noita.hardmod/files/modules/spell_variety/scripts/damage_utils.lua" )

local MAX_FRAMES = 1800

local proj_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( proj_id )
local nearest_player = EntityGetClosestWithTag( x, y, "player_unit" ) -- iffy but cba

local last_frame_used = utils.GetInternalInt( nearest_player, "hardmod_big_shot_last_frame_used" ) or 0
local frames_since_last_use = GameGetFrameNum() - last_frame_used
local mtp = math.min( utils.Remap( frames_since_last_use, 0, MAX_FRAMES, 1.0, 4.0 ), 4.0 )

MultiplyProjDmg( proj_id, mtp, "big_shot" )
utils.SetInternalInt( nearest_player, "hardmod_big_shot_last_frame_used", GameGetFrameNum() )

-- play a sound effect based on how charged the shot was
local x, y = EntityGetTransform( proj_id )
if frames_since_last_use >= MAX_FRAMES then
	GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/black_hole_big/create", x, y )
elseif frames_since_last_use >= ( MAX_FRAMES / 2 ) then
	GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/black_hole/create", x, y )
end
