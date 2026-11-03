dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

AddEnemies(g_big_enemies, {
	{
		prob = 0.3,
		entity = "data/entities/animals/fungus_giga.xml"
	},
	{
		prob = 0.1,
		entity = "data/entities/animals/barfer.xml"
	},
	{
		prob = 0.03,
		entity = "data/entities/animals/weakspirit.xml",
	},
})
