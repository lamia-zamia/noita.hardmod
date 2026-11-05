dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

PatchEnemies(g_small_enemies, {
	[""] = { prob = 0.1 },
	["data/entities/animals/sniper_hell.xml"] = { ng = 1 },
})

PatchEnemies(g_big_enemies, {
	[""] = { prob = 0.2 },
})

AddEnemies(g_small_enemies, {
	{
		prob = 0.08,
		entity = "data/entities/animals/ant.xml"
	},
	{
		prob = 0.09,
		min_count = 1,
		max_count = 2,
		entity = "mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_mummy.xml"
	}
})
