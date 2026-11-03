dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

PatchEnemies(g_big_enemies, {
  ["data/entities/animals/tank_super.xml"] = { ng = 2 },
})

AddEnemies(g_small_enemies, {
	{
		prob = 0.1,
		entity = "data/entities/animals/wizard_dark.xml",
	},
	{
		prob = 0.1,
		entity = "data/entities/animals/wizard_twitchy.xml",
	},
	{
		prob = 0.1,
		entity = "data/entities/animals/ant.xml"
	},
	{
		prob = 0.05,
		entity = "data/entities/animals/acidshooter.xml"
	},
	{ -- PWs and NG+
		ngpluslevel = 2, prob = 0.09,
		entity 	= "data/entities/animals/weakspirit.xml",
	},
})
