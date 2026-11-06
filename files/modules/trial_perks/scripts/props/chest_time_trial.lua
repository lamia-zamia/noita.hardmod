dofile_once("data/scripts/lib/utilities.lua")
local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" )

-------------------------------------------------------------------------------

local function drop_wand( x, y )
	local chest_id = GetUpdatedEntityID()
	local x, y = EntityGetTransform( chest_id )

	local wand_tiers = {
		"data/entities/items/wand_level_01.xml",
		"data/entities/items/wand_level_02.xml",
		"data/entities/items/wand_level_03.xml",
		"data/entities/items/wand_level_04.xml",
		"data/entities/items/wand_level_05.xml",
		"data/entities/items/wand_level_06.xml",
		"data/entities/items/wand_level_10.xml",
	}
	-- 0-6 points based on hm depth, 0-4 based on completion speed
	local hm_visits = tonumber( GlobalsGetValue( "HOLY_MOUNTAIN_VISITS", "0" ) )
	if string.find( GameTextGetTranslatedOrNot( BiomeMapGetName( x, y ) ), "Lab" ) then
		hm_visits = hm_visits + 1
	end
	local chest_tier = utils.GetInternalInt( chest_id, "hardmod_trophy_chest_tier" ) or 1
	local wand_tier_index = math.min( hm_visits + ( chest_tier - 1 ), #wand_tiers )
	local wand_lvl = ( hm_visits - 1 ) + ( 2 * ( chest_tier - 1 ) )

	local wand_entity = EntityLoad( wand_tiers[wand_tier_index],  x, y - 12 )
	local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )
	local wand = EZWand( wand_entity )
	wand:SetName( "Aika", true )
	wand.shuffle = false
	wand.spellsPerCast = 1
	wand.castDelay = Random( 20, 25 )
	wand.rechargeTime = wand.castDelay + Random( 7, 15 )
	wand.manaMax = Random( 215, 295 ) * ( wand_lvl + 1 )
	wand.manaChargeSpeed = Random( 35, 50 ) * ( wand_lvl + 1 )
	wand.capacity = 5 + ( wand_lvl * 2 ) + Random( -1, 1 )
	wand.spread = Random( -3, 3 )
	wand:DetachSpells()

	local preset_spell_count = 3
	for i=1, preset_spell_count do
		wand:RemoveSpellAtIndex( wand.capacity - ( preset_spell_count + i ) )
	end
    wand:AddSpells( "HARDMOD_ALT_FIRE_ANYTHING", "HARDMOD_BLINK", "TELEPORT_PROJECTILE_SHORT" )
	wand:SetSprite( "mods/noita.hardmod/files/modules/trial_perks/gfx/items/wand_aika.png", 10, 5, 18, 0 )
	wand:PlaceAt( x, y - 12 )
end

function on_open( entity_item )
	local x, y = EntityGetTransform( entity_item )
	local rand_x = x
	local rand_y = y

	-- PositionSeedComponent
	local position_comp = EntityGetFirstComponent( entity_item, "PositionSeedComponent" )
	if( position_comp ) then
		rand_x = tonumber(ComponentGetValue( position_comp, "pos_x") )
		rand_y = tonumber(ComponentGetValue( position_comp, "pos_y") )
	end

	SetRandomSeed( rand_x, rand_y )

	drop_wand( x, y )
	EntityLoad( "data/entities/particles/image_emitters/chest_effect.xml", x, y )
end

function item_pickup( entity_item, entity_who_picked, name )
	on_open( entity_item )
	
	EntityKill( entity_item )
end

function physics_body_modified( is_destroyed )
	local entity_item = GetUpdatedEntityID()
	
	on_open( entity_item )

	edit_component( entity_item, "ItemComponent", function(comp,vars)
		EntitySetComponentIsEnabled( entity_item, comp, false )
	end)
	
	EntityKill( entity_item )
end
