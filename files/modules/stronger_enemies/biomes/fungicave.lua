dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

AddEnemies(g_small_enemies, {
	{
		prob = 0.08,
		entity = "mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_wizard_confusion.xml"
	},
})

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
		prob = 0.04,
		entity = "data/entities/animals/weakspirit.xml",
	},
})
