local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local wand_entity = GetUpdatedEntityID()
local x, y = EntityGetTransform( wand_entity )
local player = EntityGetRootEntity( wand_entity )

local item_comp = EntityGetFirstComponentIncludingDisabled( wand_entity, "ItemComponent" )
if not item_comp then return end
if not player then return end

-- remove red particles from this wand
utils.EntityRemoveAllByTag( wand_entity, "hardmod_evil_wand_temp" )

-- this code comes from orb_confusion.lua
EntitySetTransform(wand_entity, x, y)
EntityRemoveFromParent(wand_entity)
EntitySetComponentsWithTagEnabled(wand_entity, "enabled_in_world", true)

local icomp = EntityGetFirstComponentIncludingDisabled(wand_entity, "ItemComponent")
if icomp and EntityHasTag(wand_entity, "wand") then
	local slot_x, slot_y = ComponentGetValue2(icomp, "inventory_slot")

	ComponentSetValue2(icomp, "inventory_slot", 3 - slot_x, slot_y)
	ComponentSetValue2( item_comp, "has_been_picked_by_player", false )
end
-- until here

local inv2_comp = EntityGetFirstComponentIncludingDisabled( player, "Inventory2Component" )
if inv2_comp then
	ComponentSetValue2( inv2_comp, "mActiveItem", 0 )
end

local sx = x + Random( -4, 4 )
local sy = y + Random( -4, 4 )
EntityLoad( "mods/noita.hardmod/files/modules/enemy_perks/entities/aerolord_shockwave.xml", sx, sy )
EntityLoad( "mods/noita.hardmod/files/modules/haunted_wands/entities/evil_wand_pickup_particles.xml", sx, sy )

local evil_wand_ghost = EntityLoad( "mods/noita.hardmod/files/modules/haunted_wands/entities/evil_wand_ghost.xml", sx, sy )
local dmg_comp = EntityGetFirstComponentIncludingDisabled( evil_wand_ghost, "DamageModelComponent" )
if dmg_comp then
	local wand_level = utils.GetInternalInt( wand_entity, "hardmod_wand_level" ) or 1
	local hp = math.min( wand_level * 4, 4 )
	ComponentSetValue2( dmg_comp, "max_hp", hp )
	ComponentSetValue2( dmg_comp, "hp", hp )
end

local ai_comp = EntityGetFirstComponentIncludingDisabled( evil_wand_ghost, "AnimalAIComponent" )
if ai_comp then
	ComponentSetValue2( ai_comp, "ai_state", 0 )
	ComponentSetValue2( ai_comp, "ai_state_timer", GameGetFrameNum() + 90 )
end

EntityRemoveComponent( wand_entity, GetUpdatedComponentID() )
