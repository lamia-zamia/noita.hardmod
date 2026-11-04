dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

AddEnemies(g_small_enemies, {
	{
		prob = 0.1,
		entity = "data/entities/animals/ant.xml"
	},
})
