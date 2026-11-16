local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )

local desirable_spells = {
	"TELEPORT_PROJECTILE_SHORT", -- mobility
	"TELEPORT_PROJECTILE",
	"HARDMOD_MINI_CHAINSAW", -- chainsaws
	"CHAINSAW",
	"MANA_REDUCE", -- stat enhancers
	"RECHARGE",
	"BLACK_HOLE", -- diggers
	"MATTER_EATER",
	"LIFETIME", -- lifetime
	"LIFETIME_DOWN",
	"NOLLA",
	"HEAVY_SHOT", -- modifiers
	"HARDMOD_BIG_SHOT",
	"DAMAGE_FOREVER",
	"SPELLS_TO_POWER",
	"MONEY_MAGIC",
	"LARPA_DOWNWARDS",
	"HEAL_BULLET", -- healers
	"ANTIHEAL",
	"XRAY", -- utility
	"BOMB_DETONATOR",
	"ENERGY_SHIELD_SECTOR", -- passives
}

-- local dangerous_spells = {
-- 	"DISC_BULLET_BIG",
-- 	"CRUMBLING_EARTH",
-- 	"MEGALASER",
-- 	"ROCKET",
-- 	"ROCKET_TIER_2",
-- 	"ROCKET_TIER_3",
-- 	"THUNDERBALL",
-- 	"DARKFLAME",
-- }

local function split_string( inputstr, sep )
	sep = sep or "%s"
	local t= {}
	for str in string.gmatch( inputstr, "([^"..sep.."]+)" ) do
		table.insert( t, str )
	end
	return t
end

local function get_actions_lua_data( action_id )
    if not actions then dofile_once("data/scripts/gun/gun_actions.lua") end
	-- local actions = dofile_once("mods/noita.hardmod/lib/gun_actions_indexed.lua")
    for i,action in ipairs( actions ) do
        if action.id == action_id then
            return action
        end
    end
    return nil
end

local function does_player_have_spell( action_id )
	local spells = EntityGetWithTag( "card_action" )
	for _,spell in ipairs( spells ) do
		local ia_comp = EntityGetFirstComponentIncludingDisabled( spell, "ItemActionComponent" )
		if ia_comp then
			local spell_id = ComponentGetValue2( ia_comp, "action_id" )
			if spell_id == action_id then
				return true
			end
		end
	end
	return false
end

local function is_spell_appropriate_tier( action_id, level )
	-- check if the level of the wand matches the levels of the spells
	local correct_tier = true
	local spell_data = get_actions_lua_data( action_id )
	if spell_data then
		local lowest_spawn_level = tonumber( split_string( spell_data.spawn_level, ',' )[1] )
		return lowest_spawn_level > level
	end

	return false
end

local function generate_spells( wand, level )
	wand:RemoveSpells()
	if level > 6 and level < 10 then level = 6 end

	-- fill up the rest of the wand with random spells
	local x, y = EntityGetTransform( wand.entity_id )
	local max_spell_count = ( level * 3 ) + Random( -1, 1 )
	for i=1, math.min( wand.capacity, max_spell_count ) do
		local spell_to_add = GetRandomAction( x+i, y-i, level )
		local j = 1
		while spell_to_add == "HARDMOD_ALT_FIRE_ANYTHING" or spell_to_add == "RESET" do
			spell_to_add = GetRandomAction( x+i+j, y+i+j, level )
			j = j + 1
		end
		wand:AddSpells( spell_to_add )
	end
end

local function host_evil_ghost( wand, level )
	local wand_entity = wand.entity_id
	local x, y = EntityGetTransform( wand_entity )

	-- turn the new wand particles red
	local spe_comp = EntityGetFirstComponentIncludingDisabled( wand_entity, "SpriteParticleEmitterComponent" )
	if spe_comp then
		ComponentSetValue2( spe_comp, "color", 1, 0.25, 0.25, 0.5 )
	end

	EntityAddTag( wand_entity, "hardmod_evil_wand" )
	EntityAddComponent2( wand_entity, "LuaComponent", {
		_tags = "hardmod_evil_wand_temp",
		script_item_picked_up = "mods/noita.hardmod/files/modules/haunted_wands/scripts/evil_wand_on_pickup.lua",
		execute_every_n_frame = -1,
	})
	EntityAddComponent2( wand_entity, "LuaComponent", {
		_tags = "hardmod_evil_wand_temp",
		script_source_file = "mods/noita.hardmod/files/modules/haunted_wands/scripts/evil_wand_update.lua",
		execute_every_n_frame = 6,
	})
	EntityAddComponent2( wand_entity, "VariableStorageComponent", {
		name = "hardmod_wand_level",
		value_int = level,
	})
	EntityAddComponent2( wand_entity, "AudioLoopComponent", {
		_tags = "hardmod_evil_wand_temp",
		file = "data/audio/Desktop/projectiles.bank",
		event_name = "player_projectiles/epilogue/wall/movement_loop",
		m_volume = 0.3,
		auto_play_if_enabled = true,
	})

	EntityAddChild( wand_entity,
		EntityLoad( "mods/noita.hardmod/files/modules/haunted_wands/entities/evil_wand_particles.xml", x, y ) )

	generate_spells( wand, level )
	-- custom spell generation toggle was moved to line 89
end

local _generate_gun = generate_gun
function generate_gun( cost, level, force_unshuffle )
	local wand_entity = GetUpdatedEntityID()
	local x, y = EntityGetTransform( wand_entity )

	local possess_wand = false
	biome_index = dofile_once( "mods/noita.hardmod/lib/biome_index.lua" )
	local biome = biome_index[DebugBiomeMapGetFilename( x, y )]
	SetRandomSeed( GameGetFrameNum()-level, -GameGetFrameNum()+level )
	if biome ~= "holy_mountain" and Random( 1, 20 ) == 10 then
		-- level = level + 1
		possess_wand = true
	end

	_generate_gun( cost, level, force_unshuffle )
	wand = EZWand( wand_entity )
	if wand.capacity >= 5 and possess_wand then
		host_evil_ghost( wand, level )
	end
end
