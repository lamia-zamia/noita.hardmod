dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

AddEnemies(g_big_enemies, {
	{
		prob = 0.2,
		entity = "data/entities/animals/weakspirit.xml",
	},
})
