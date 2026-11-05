dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

AddEnemies(g_small_enemies, {
	{
		prob = 0.1,
		min_count = 1,
		max_count = 2,
		entity = "mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_mummy.xml"
	}
})
