local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )

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

-- local desirable_spells = {
-- 	-- mobility
-- 	"TELEPORT_PROJECTILE_SHORT",
-- 	-- wand enhancers
-- 	"MANA_REDUCE",
-- 	"RECHARGE",
-- 	-- diggers
-- 	"BLACK_HOLE",
-- 	"MATTER_EATER",
-- 	-- damage modifiers
-- 	"DAMAGE",
-- 	"HEAVY_SHOT",
-- 	-- healers
-- 	"HEAL_BULLET",
-- }

local modifiers = {
	-- damage
	{
		"DAMAGE",
	},
	{
		"HEAVY_SHOT",
	},
	{
		"HARDMOD_BIG_SHOT",
	},
	-- recharge/mana
	{
		"RECHARGE",
	},
	{
		"MANA_REDUCE",
	},
	-- lifetime
	{
		"LIFETIME",
	},
	{
		"LIFETIME_DOWN",
	},
	-- trajectory
	{
		"HOMING",
	},
	{
		"HOMING_SHORT",
	},
	{
		"CHAOTIC_ARC",
	},
	{
		"SPEED",
	},
	{
		"SPREAD_REDUCE",
	},
	-- aoe modifiers
	{
		"GRAVITY_FIELD_ENEMY",
	},
}

local triggers = {
	{
		"LIGHT_BULLET_TRIGGER",
	},
	{
		"LIGHT_BULLET_TRIGGER",
		"LIGHT_BULLET_TRIGGER",
	},
	{
		"BULLET_TRIGGER",
	},
	{
		"HEAVY_BULLET_TRIGGER",
	},
	{
		"HEAVY_BULLET_TRIGGER",
		"HEAVY_BULLET_TRIGGER",
	},
	{
		"SLOW_BULLET_TRIGGER",
	},
	{
		"BUBBLESHOT_TRIGGER",
	},
	{
		"HARDMOD_ECHO_SHOT_TIMER",
	},
}

local payloads = {
	{
		"PENTAGRAM_SHAPE",
		"SPORE_POD",
		"SPORE_POD",
		"SPORE_POD",
		"SPORE_POD",
		"SPORE_POD",
	},
	{
		"BURST_2",
		"BLACK_HOLE",
		"DARKFLAME",
	},
	{
		"ANTIHEAL",
	},
	{
		"ROCKET",
	},
	{
		"ROCKET_TIER_2",
	},
	{
		"ROCKET_TIER_3",
	},
	{
		"SCATTER_3",
		"FLAMETHROWER",
		"FLAMETHROWER",
		"FLAMETHROWER",
	},
	{
		"SPEED",
		"BOUNCE_SPARK",
		"SCATTER_3",
		"BUBBLESHOT",
		"BUBBLESHOT",
		"BUBBLESHOT",
	},
	{
		"NOLLA",
		"DYNAMITE",
	},
	{
		"WALL_SQUARE",
	},
	{
		"TELEPORT_PROJECTILE_SHORT",
		"DEATH_CROSS_BIG",
	},
	{
		"W_SHAPE",
		"HEAVY_BULLET",
		"HEAVY_BULLET",
		"HEAVY_BULLET",
	},
	{
		"BURST_2",
		"HARDMOD_MINI_CHAINSAW",
		"CHAINSAW",
		"CHAINSAW",
	},
	{
		"BURST_3",
		"CHAINSAW",
		"CHAINSAW",
		"CHAINSAW",
	},
}

-- local function does_player_have_spell( action_id )
-- 	local spells = EntityGetWithTag( "card_action" )
-- 	for _,spell in ipairs( spells ) do
-- 		local ia_comp = EntityGetFirstComponentIncludingDisabled( spell, "ItemActionComponent" )
-- 		if ia_comp then
-- 			local spell_id = ComponentGetValue2( ia_comp, "action_id" )
-- 			if spell_id == action_id then
-- 				return true
-- 			end
-- 		end
-- 	end
-- 	return false
-- end

local function split_string( inputstr, sep )
	sep = sep or "%s"
	local t= {}
	for str in string.gmatch( inputstr, "([^"..sep.."]+)" ) do
		table.insert( t, str )
	end
	return t
end

local function calculate_sequence_mana_cost( sequence )
	local sequence_mana_cost = 0
	for _,action_id in ipairs( sequence ) do
		local spell_data = get_actions_lua_data( action_id )
		if spell_data then
			sequence_mana_cost = sequence_mana_cost + spell_data.mana
		end
	end
	return sequence_mana_cost
end

local function can_cast_sequence( sequence, level, slots_remaining, mana_remaining )
	-- check if enough mana
	local enough_mana = calculate_sequence_mana_cost( sequence ) <= mana_remaining

	-- check if enough space
	local enough_space = slots_remaining >= #sequence

	-- check if the level of the wand matches the levels of the spells
	local correct_tier = true
	for _,action_id in ipairs( sequence ) do
		local spell_data = get_actions_lua_data( action_id )
		if spell_data then
			local lowest_spawn_level = tonumber( split_string( spell_data.spawn_level, ',' )[1] )
			if lowest_spawn_level > level then
				correct_tier = false
				break
			end
		end
	end

	return enough_mana and enough_space and correct_tier
end

local function try_generate_spell_sequence( wand_entity, level )
	local wand = EZWand( wand_entity )

	local trigger_mods = {}
	local trigger = {}
	local payload_mods = {}
	local payload = {}

	wand:RemoveSpells()
	local slots_remaining = wand.capacity
	local mana_remaining = wand.manaMax

	-- first pick a payload
	local candidates = {}
	for _,option in pairs( payloads ) do
		if can_cast_sequence( option, level, slots_remaining, mana_remaining ) then
			table.insert( candidates, option )
		end
	end
	payload = candidates[Random(1, #candidates)]
	slots_remaining = slots_remaining - #payload
	mana_remaining = mana_remaining - calculate_sequence_mana_cost( payload )

	-- 60% chance to have a modifier
	if slots_remaining > 1 and mana_remaining > 0 and Random( 1, 10 ) <= 6 then
		local candidates = {}
		for _,option in pairs( modifiers ) do
			if can_cast_sequence( option, level, slots_remaining, mana_remaining ) then
				table.insert( candidates, option )
			end
		end
		trigger_mods = candidates[Random(1, #candidates)]
		slots_remaining = slots_remaining - #trigger_mods
		mana_remaining = mana_remaining - calculate_sequence_mana_cost( trigger_mods )
	end

	-- 40% chance to have the payload on a trigger
	if slots_remaining > 1 and mana_remaining > 0 and Random( 1, 10 ) <= 4 then
		local candidates = {}
		for _,option in pairs( triggers ) do
			if can_cast_sequence( option, level, slots_remaining, mana_remaining ) then
				table.insert( candidates, option )
			end
		end
		trigger = candidates[Random(1, #candidates)]
		slots_remaining = slots_remaining - #trigger
		mana_remaining = mana_remaining - calculate_sequence_mana_cost( trigger )

		-- 40% within that to give the payload some modifiers
		if slots_remaining > 1 and mana_remaining > 0 and Random( 1, 10 ) <= 4 then
			local candidates = {}
			for _,option in pairs( modifiers ) do
				if can_cast_sequence( option, level, slots_remaining, mana_remaining ) then
					table.insert( candidates, option )
				end
			end
			payload_mods = candidates[Random(1, #candidates)]
			slots_remaining = slots_remaining - #payload_mods
			mana_remaining = mana_remaining - calculate_sequence_mana_cost( payload_mods )
		end
	end

	for _,spell in ipairs( trigger_mods ) do
		wand:AddSpells( spell )
	end
	for _,spell in ipairs( trigger ) do
		wand:AddSpells( spell )
	end
	for _,spell in ipairs( payload_mods ) do
		wand:AddSpells( spell )
	end
	for _,spell in ipairs( payload ) do
		wand:AddSpells( spell )
	end
end

-- local function add_random_desirable_spell( wand_entity, level )
-- 	local wand = EZWand( wand_entity )

-- 	-- check if the wand has space for the spell(s)
-- 	local preset_spell_count = 2
-- 	if wand:GetFreeSlotsCount() < preset_spell_count then

-- 		-- first try to add more capacity
-- 		if wand.capacity <= 25 - preset_spell_count then
-- 			wand.capacity = wand.capacity + preset_spell_count
-- 		-- otherwise, try to remove some spells
-- 		else
-- 			for i=1, preset_spell_count do
-- 				wand:RemoveSpellAtIndex( wand.capacity - ( preset_spell_count + i ) )
-- 			end
-- 		end
-- 	end

-- 	local candidates = {}
-- 	for _,action_id in ipairs( desirable_spells ) do
-- 		if not does_player_have_spell( action_id ) then
-- 			table.insert( candidates, action_id )
-- 		end
-- 	end

-- 	if #candidates > 0 then
-- 		wand:AddSpells( "HARDMOD_ALT_FIRE_ANYTHING", random_from_array( candidates ) )
-- 	end
-- end

local function maybe_host_evil_ghost( wand_entity, level )
	local x, y = EntityGetTransform( wand_entity )
	biome_index = dofile_once( "mods/noita.hardmod/lib/biome_index.lua" )
	local biome = biome_index[DebugBiomeMapGetFilename( x, y )]

	SetRandomSeed( GameGetFrameNum()-level, -GameGetFrameNum()+level )
	if Random( 0, 100 ) < 100 and biome ~= "holy_mountain" then
		local wand_entity = GetUpdatedEntityID()
		local x, y = EntityGetTransform( wand_entity )

		-- turn the new wand particles red
		local spe_comp = EntityGetFirstComponentIncludingDisabled( wand_entity, "SpriteParticleEmitterComponent" )
		if spe_comp then
			ComponentSetValue2( spe_comp, "color", 1, 0.25, 0.25, 0.5 )
		end

		EntityAddTag( wand_entity, "hardmod_evil_wand" )
		EntityAddComponent2( wand_entity, "LuaComponent", {
			script_item_picked_up = "mods/noita.hardmod/files/modules/haunted_wands/scripts/evil_wand_on_pickup.lua",
			execute_every_n_frame = -1,
		})
		EntityAddComponent2( wand_entity, "VariableStorageComponent", {
			name = "hardmod_wand_level",
			value_int = level,
		})
		EntityAddChild( wand_entity,
			EntityLoad( "mods/noita.hardmod/files/modules/haunted_wands/entities/evil_wand_particles.xml", x, y ) )

		try_generate_spell_sequence( wand_entity, level )
		-- add_random_desirable_spell( wand_entity, level )
	end
end

local _generate_gun = generate_gun
function generate_gun( cost, level, force_unshuffle )
	_generate_gun( cost, level, force_unshuffle )
	maybe_host_evil_ghost( GetUpdatedEntityID(), level )
end
