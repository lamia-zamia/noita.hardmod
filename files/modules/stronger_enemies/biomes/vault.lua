dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

PatchEnemies(g_small_enemies, {
	[""] = { prob = 0.65 },
  	["data/entities/animals/drone_shield.xml"] = { ng = 2 },
})

PatchEnemies(g_big_enemies, {
	[""] = { prob = 0.7 },
})

AddEnemies(g_small_enemies, {
	{
		prob = 0.2,
		entity = "data/entities/animals/shotgunner_hell.xml",
	},
	{
		prob = 0.08,
		entity = "data/entities/animals/assassin.xml"
	},
		{
		prob = 0.35,
		entity = "data/entities/animals/weakspirit.xml",
	},
	{
		prob = 0.2,
		entity = "data/entities/animals/roboguard_big.xml"
	},
	{
		prob = 0.11,
		entity = "data/entities/animals/sniper_hell.xml",
	},
	{
		prob = 0.25,
		min_count = 2,
		max_count = 3,
		entity = "data/entities/animals/crypt/skullrat.xml"
	},
})

AddEnemies(g_big_enemies, {
	{
		prob = 0.1,
		entity = "mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_wizard_confusion.xml"
	},
	{
		prob = 0.09,
		entity = "data/entities/animals/wizard_poly.xml"
	},
	{
		prob = 0.05,
		entity = "data/entities/animals/thundermage_big.xml"
	},
	-- add skullflys after this step
	-- add skullflys after this step
	-- add skullflys after this step
	{
		prob = 0.2,
		entity = "data/entities/animals/crypt/skullfly.xml"
	},
})
