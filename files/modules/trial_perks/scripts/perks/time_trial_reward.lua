local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
dofile_once( "mods/noita.hardmod/files/modules/trial_perks/scripts/trial_perk_utils.lua" )

utils.SetInternalInt( player, "hardmod_time_trial_start_y", 0 )

local function spawn_staff( x, y, frames_left )
    local hm_visits = tonumber( GlobalsGetValue( "HOLY_MOUNTAIN_VISITS", "0" ) )
    local wand_lvl = hm_visits
	local tier = 1
	if frames_left >= 2700 then
		tier = 3
	elseif frames_left <= 1800 then
		tier = 2
	end

	local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )
	local wand = EZWand()
	wand:SetName( "Aika", true )
	wand.shuffle = false
	wand.spellsPerCast = 1
	wand.castDelay = 30
	wand.rechargeTime = 40
	wand.manaMax = 240 + ( wand_lvl * 120 )
	wand.manaChargeSpeed = 90 + ( wand_lvl * 30 )
	wand.capacity = 5 + ( wand_lvl * 3 )
	wand.spread = 0
	wand:AddSpells( "TELEPORT_PROJECTILE_SHORT", "HARDMOD_ALT_FIRE_ANYTHING", { "HARDMOD_BLINK", tier } )
	wand:SetSprite( "mods/noita.hardmod/files/modules/trial_perks/gfx/items/wand_aika.png", 8, 4, 19, 0 )
	wand:PlaceAt( x, y )
	
	return true
end

local player = GetUpdatedEntityID()
local px, py = EntityGetTransform( player )
AddFlagPersistent( "hardmod_time_trial_passed" )

GamePrintImportant( "$hardmod_perk_time_trial_msg_pass" )
EntityLoad( "data/entities/particles/image_emitters/perk_effect.xml", px, py - 8 )
GamePlaySound( "data/audio/Desktop/event_cues.bank", "event_cues/chest/create", px, py - 8 )

local game_effect = EntityGetAllChildren( player, "hardmod_time_trial_game_effect" )[1]
if game_effect then
	local effect_comp = EntityGetFirstComponentIncludingDisabled( game_effect, "GameEffectComponent" )
	if effect_comp then
		local frames_left = ComponentGetValue2( effect_comp, "frames" )
		spawn_staff( px, py - 8, frames_left )
	end
end

utils.EntityRemoveAllByTag( player, "hardmod_time_trial" )
SwapPerkIconForSpent( player, "$hardmod_perk_time_trial_name", true )
