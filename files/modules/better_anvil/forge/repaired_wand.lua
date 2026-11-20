dofile_once("data/scripts/gun/procedural/gun_procedural_better.lua")
local EZWand = dofile_once("mods/noita.hardmod/lib/ezwand.lua")
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

return function (x, y)
	local wand_entity = EntityLoad("data/entities/items/wand_level_05_better.xml", x, y)
	local wand = EZWand(wand_entity)
	local passives_to_spawn = Random(1, 3)

	while wand:GetFreeSlotsCount() < passives_to_spawn do
		wand:RemoveSpellAtIndex(wand.capacity - passives_to_spawn - 1)
	end

	for i=1,passives_to_spawn do
		local spell_id = GetRandomActionWithType(x, y, 5, ACTION_TYPE_PASSIVE, i)
		wand:AddSpells(spell_id)
	end
end
