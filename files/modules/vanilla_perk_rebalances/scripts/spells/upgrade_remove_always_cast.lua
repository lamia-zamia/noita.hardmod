local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" )
dofile_once( "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/scripts/perks/toolbox_utils.lua" )

local card_entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent( card_entity_id )
local last_wand_tried = utils.GetInternalInt( card_entity_id, "last_wand_tried" )

if parent_id == nil then return end
if not EZWand.IsWand( parent_id ) then return end
if last_wand_tried ~= nil and last_wand_tried == parent_id then return end
if EntityHasTag( parent_id, "hardmod_toolbox" ) then return end

-- do the upgrading
local wand = EZWand( parent_id )
if RemoveRandomAlwaysCast( wand ) then
	local x, y = EntityGetTransform( card_entity_id )
	GamePlaySound( "data/audio/Desktop/misc.bank", "game_effect/regeneration/tick", x, y )
	EntityKill( card_entity_id )
elseif utils.GetInternalInt( card_entity_id, "last_wand_tried" ) ~= parent_id then
	local x, y = EntityGetTransform( card_entity_id )
	GamePlaySound( "data/audio/Desktop/misc.bank", "collision/barrel_water/destroy", x, y )
	utils.SetInternalInt( card_entity_id, "last_wand_tried", parent_id )
end
utils.SetInternalInt( card_entity_id, "last_wand_tried", parent_id )