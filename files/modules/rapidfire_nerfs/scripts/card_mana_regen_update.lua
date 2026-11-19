
local entity_id = GetUpdatedEntityID()
local wand_entity_id = EntityGetParent(entity_id)
local EZWand = dofile_once("mods/noita.hardmod/lib/ezwand.lua")

local perc = 0.2 -- 20%

if wand_entity_id and EZWand.IsWand(wand_entity_id) then
	local wand = EZWand(wand_entity_id)
	wand.mana = math.min(
		math.max(wand.manaMax, wand.mana), --cap mana to max mana or current mana, whichever is higher
		wand.mana + (wand.manaMax * perc * (1/60))
	)
end