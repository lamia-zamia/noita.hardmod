local lootlib = dofile_once("mods/noita.hardmod/lib/lootlib.lua")---@type lootlib

local chest = lootlib.get_loot_table("chest_random")

local max_allowed_chest_level = 3

local random_card = lootlib.get_label(chest, "random_card")
if random_card then
	random_card.card_filter = function(card)
		---@type string?
		local levels = card.spawn_level

		if not levels then return false end

		for part in levels:gmatch("[^,]+") do
			local level = tonumber(part)
			if level and level <= max_allowed_chest_level then
				return true
			end
		end

		return false
	end
end
