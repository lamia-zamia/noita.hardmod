local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local function spawn_staff( x, y, player )
    local hm_visits = tonumber( GlobalsGetValue( "HOLY_MOUNTAIN_VISITS", "0" ) )
    local wand_lvl = hm_visits

	local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )
	local wand = EZWand()
	wand:SetName( "Lasi", true )
	wand.shuffle = false
    wand.spellsPerCast = 1
    wand.castDelay = 5
    wand.rechargeTime = 6
    wand.manaMax = 64 + ( 128 + Random( -4, 4 ) ) * wand_lvl
    wand.manaChargeSpeed = 96 + ( 192 + Random( -4, 4 ) ) * wand_lvl
    wand.capacity = ( wand_lvl * 4 ) + 1
    wand.spread = Random( -8, -2 )
	wand:AddSpells( "LIGHT_BULLET", "BOMB", "BOMB", "HARDMOD_ALT_FIRE_ANYTHING", "HARDMOD_PARRY" )
	wand:RemoveSpells( "BOMB", -1 )
	wand:SetSprite( "mods/noita.hardmod/files/modules/trial_perks/gfx/items/wand_lasi.png", 6, 4, 18, 0 )
	wand:PlaceAt( x, y )
	EntityAddTag( wand.entity_id, "hardmod_glass_wand" )

	local players = EntityGetWithTag( "player_unit" )
	if players then
		for i,player in ipairs( players ) do
			local luacomps = EntityGetComponent( player, "LuaComponent", "hardmod_glass_wand_on_damage" )
			if luacomps or #luacomps == 0 then
			    EntityAddComponent2( player, "LuaComponent", {
			    	_tags = "hardmod_glass_wand_on_damage",
						script_damage_received = "mods/noita.hardmod/files/modules/trial_perks/scripts/items/glass_wand_on_damage.lua",
						execute_every_n_frame = "-1",
			    })
			end
		end
	end
	
	return true
end

local player = GetUpdatedEntityID()

GamePrintImportant( "$hardmod_perk_glass_heart_msg_pass" )
local px, py = EntityGetTransform( player )
-- EntityLoad( "data/entities/particles/image_emitters/perk_effect.xml", px, py - 8 )
-- GamePlaySound( "data/audio/Desktop/event_cues.bank", "event_cues/chest/create", px, py - 8 )
EntityLoad( "data/entities/particles/image_emitters/heart_fullhp_effect.xml", px, py - 12 )

spawn_staff( px, py - 8 )

dofile_once( "mods/noita.hardmod/files/modules/trial_perks/scripts/trial_perk_utils.lua" )
utils.EntityRemoveAllByTag( player, "hardmod_glass_heart" )
SwapPerkIconForSpent( player, "$hardmod_perk_glass_heart_name", true )
utils.SetInternalInt( player, "hardmod_glass_heart_start_y", 0 )
