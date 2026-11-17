local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )

local shield = EntityLoad( "mods/noita.hardmod/files/modules/vanilla_bosses/entity/gold_shield_squiddy.xml", x, y )
EntityAddChild( entity_id, shield )
EntitySetComponentsWithTagEnabled( shield, "hardmod_gold_shield_active", false )
EntitySetComponentsWithTagEnabled( shield, "hardmod_gold_shield_inactive", true )

EntityAddComponent2( entity_id, "LuaComponent", {
	_tags = "perk_component,hardmod_gold_shield",
	script_damage_received = "mods/noita.hardmod/files/modules/vanilla_bosses/scripts/perks/gold_shield_on_damage.lua",
	execute_every_n_frame = -1,
})

utils.SetInternalInt( entity_id, "boss_cage_aura_frames_before_max", 3600 )
utils.SetInternalInt( entity_id, "boss_cage_aura_inner_radius_init", 375 )
utils.SetInternalInt( entity_id, "boss_cage_aura_inner_radius_shrink", 250 )
EntityAddChild( entity_id, EntityLoad( "mods/noita.hardmod/files/modules/vanilla_bosses/entity/boss_cage_aura_dormant.xml", x, y ) )
