dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

PatchEnemies(g_big_enemies, {
  ["data/entities/animals/crypt/thundermage.xml"] = { prob = 0.1 }
})

AddEnemies(g_big_enemies, {
	{
		prob = 0.3,
		entity = "data/entities/animals/weakspirit.xml",
	},
	{
		prob = 0.05,
		entity = "data/entities/animals/thundermage_big.xml"
	},
})
