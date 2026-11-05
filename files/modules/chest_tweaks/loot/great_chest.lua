local lootlib = dofile_once("mods/noita.hardmod/lib/lootlib.lua")---@type lootlib

local chest = lootlib.get_loot_table("chest_random_super_base")

local rain = lootlib.get_label(chest, "rain_gold") or {}
rain.success.entity = nil
rain.success.pick_weighted = {
	{ weight = 15, entity = "data/entities/projectiles/rain_gold.xml" },
	{ weight = 10, entity = "data/entities/misc/chest_rain.xml" },
	{ weight = 5, entity = "data/entities/misc/utility_rain.xml" },
	-- { weight = 1, entity = "data/entities/misc/worm_rain.xml" },
}

lootlib.extend_loot_table(chest, {
	{
		label = "misc_items",
		weight = 6,
		pick_weighted = lootlib.get_loot_table("misc_items")
	},
})

-- {
--   weight = 10,
--   entity = "data/entities/animals/boss_wizard/statusburst.xml"
-- },
