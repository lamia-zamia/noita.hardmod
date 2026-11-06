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
	local wand_tier_index = math.min( hm_visits, #wand_tiers )
	local wand_lvl = wand_tier_index

	local wand_entity = EntityLoad( wand_tiers[wand_tier_index],  x, y - 12 )
	local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )
	local wand = EZWand( wand_entity )
	wand:SetName( "Lasi", true )

	wand.shuffle = false
    wand.spellsPerCast = 1
    wand.castDelay = Random( 5, 8 ) - wand_lvl
    wand.rechargeTime = wand.castDelay + Random( 3, 5 )
    wand.manaMax = 64 + ( 128 + Random( -4, 4 ) ) * wand_lvl
    wand.manaChargeSpeed = 96 + ( 192 + Random( -4, 4 ) ) * wand_lvl
    wand.capacity = Random( 3, 5 ) + ( wand_lvl * 3 )
    wand.spread = -wand_lvl + Random( -3, 3 )
	wand:DetachSpells()

	local preset_spell_count = 2
	for i=1, preset_spell_count do
		wand:RemoveSpellAtIndex( wand.capacity - ( preset_spell_count + i ) )
	end
    wand:AddSpells( "HARDMOD_ALT_FIRE_ANYTHING", "HARDMOD_PARRY" )
	wand:SetSprite( "mods/noita.hardmod/files/modules/trial_perks/gfx/items/wand_lasi.png", 6, 4, 18, 0 )
	wand:PlaceAt( x, y - 12 )
	EntityAddTag( wand.entity_id, "hardmod_glass_wand" )

	local players = EntityGetWithTag( "player_unit" )
	if players then
		for i,player in ipairs( players ) do
			local luacomps = EntityGetComponent( player, "LuaComponent", "hardmod_glass_wand_on_damage" )
			if luacomps == nil or #luacomps == 0 then
			    EntityAddComponent2( player, "LuaComponent", {
			    	_tags = "hardmod_glass_wand_on_damage",
					script_damage_received = "mods/noita.hardmod/files/modules/trial_perks/scripts/items/glass_wand_on_damage.lua",
					execute_every_n_frame = "-1",
			    })
			end
		end
	end
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
