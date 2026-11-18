local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local wand_entity = GetUpdatedEntityID()
local x, y = EntityGetTransform(wand_entity)

local nearby_players = EntityGetInRadiusWithTag(x, y, 16, "player_unit")

local item_comp = EntityGetFirstComponentIncludingDisabled(wand_entity, "ItemComponent")
if item_comp then
	EntitySetComponentIsEnabled(wand_entity, item_comp, nearby_players and #nearby_players > 0)
end
