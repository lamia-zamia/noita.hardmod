dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

PatchEnemies(g_small_enemies, {
	[""] = { prob = 0.3 },
})

PatchEnemies(g_big_enemies, {
	[""] = { prob = 0.4 },
	["data/entities/animals/spearbot.xml"] = { prob = 0.07 }
})

AddEnemies(g_small_enemies, {
	{
		prob = 0.2,
		entity = "data/entities/animals/shotgunner_hell.xml",
	},
	{
		prob = 0.09,
		entity = "data/entities/animals/roboguard.xml"
	},
	{
		prob = 0.1,
		entity = "data/entities/animals/weakspirit.xml",
	},
	{
		prob = 0.06,
		entity = "data/entities/animals/assassin.xml"
	},
	{
		prob = 0.07,
		entity = "data/entities/animals/vault/missilecrab.xml"
	},
	{
		prob = 0.06,
		entity = "data/entities/animals/spearbot.xml"
	},
	{
		prob = 0.15,
		entities = {
			"data/entities/animals/frog.xml",
			"data/entities/animals/frog.xml",
			"data/entities/animals/frog_big.xml",
		}
	},
})

AddEnemies(g_big_enemies, {
	{
		prob = 0.065,
		entity = "data/entities/animals/fungus_giga.xml"
	},
	{
		prob = 0.085,
		entity = "data/entities/animals/lukki/lukki_dark.xml"
	},
	{
		prob = 0.07,
		entity = "data/entities/animals/shotgunner_hell.xml",
	},
})
