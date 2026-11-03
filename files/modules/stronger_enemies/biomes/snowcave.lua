dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

PatchEnemies(g_small_enemies, {
  ["data/entities/animals/thundermage_big.xml"] = { ng = 2, prob = 0.01 },
})

PatchEnemies(g_big_enemies, {
  ["data/entities/animals/thundermage_big.xml"] = { ng = 2, prob = 0.03 },
})

AddEnemies(g_small_enemies, {
	-- is this evil
	{
		prob = 0.1,
		entity = "data/entities/animals/wizard_swapper.xml"
	},
	-- {
	-- 	prob = 0.05,
	-- 	entity 	= "data/entities/animals/wizard_neutral.xml"
	-- },
	{ -- PWs and NG+
		ngpluslevel = 2, prob = 0.09,
		entity 	= "data/entities/animals/weakspirit.xml",
	},
})

AddEnemies(g_big_enemies, {
	{
		prob = 0.05,
		entity = "data/entities/animals/wizard_poly.xml"
	},
})
