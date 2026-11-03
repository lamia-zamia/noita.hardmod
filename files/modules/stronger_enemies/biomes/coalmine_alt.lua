dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

PatchEnemies(g_big_enemies, {
  ["data/entities/animals/scavenger_clusterbomb.xml"] = { ng = 2 },
})

AddEnemies(g_small_enemies, {
	{
		prob = 0.1,
		entity = "data/entities/animals/scavenger_mine.xml",
	},
	{
		prob = 0.1,
		entity = "data/entities/animals/barfer.xml"
	},
	{ -- PWs and NG+
		ngpluslevel = 2, prob = 0.09,
		entity 	= "data/entities/animals/weakspirit.xml",
	},
})
