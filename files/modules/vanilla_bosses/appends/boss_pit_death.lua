-- dofile_once("data/scripts/lib/utilities.lua")

-- function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
-- 	local entity_id = GetUpdatedEntityID()
-- 	local x, y = EntityGetTransform( entity_id )
-- 	local flag_status = HasFlagPersistent( "card_unlocked_rain" )
	
-- 	local pw = check_parallel_pos( x )
-- 	SetRandomSeed( pw, 120 )
	
-- 	local opts = { "WORM_RAIN", "METEOR_RAIN" }
-- 	local rnd = Random( 1, #opts )
	
-- 	if flag_status then
-- 		CreateItemActionEntity( "WORM_RAIN", x - 16, y )
-- 		CreateItemActionEntity( "METEOR_RAIN", x + 16, y )
-- 	else
-- 		CreateItemActionEntity( "WORM_RAIN", x - 16, y )
-- 		CreateItemActionEntity( "METEOR_RAIN", x + 16, y )
-- 		EntityLoad( "data/entities/items/pickup/heart_fullhp.xml",  x, y )
-- 	end
	
-- 	EntityLoad( "data/entities/items/wand_unshuffle_05.xml",  x - 24, y )
-- 	EntityLoad( "data/entities/items/wand_level_06.xml",  x + 24, y )
	
-- 	AddFlagPersistent( "card_unlocked_rain" )
-- 	AddFlagPersistent( "miniboss_pit" )
-- end

local _death = death
function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
	_death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )

	local entity_id = GetUpdatedEntityID()
	local x, y = EntityGetTransform( entity_id )

	local t10_wand = EntityLoad( "data/entities/items/wand_level_10.xml",  x, y - 12 )
	local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )
	local wand = EZWand( t10_wand )
	wand:SetName( "Wand of Connoisseurs", true )
    wand:AddSpells( "WORM_RAIN", "METEOR_RAIN" )
	wand:SetSprite( "mods/noita.hardmod/files/modules/vanilla_bosses/gfx/items/wand_squidward.png", 10, 5, 18, 0 )
	-- wand:PlaceAt( x, y )

	-- spawn the perk
    dofile_once( "data/scripts/perks/perk.lua" )
	perk_spawn( x, y + 12, "HARDMOD_GOLD_SHIELD", true )
end