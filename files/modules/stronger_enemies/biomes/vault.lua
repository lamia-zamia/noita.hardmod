dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

PatchEnemies(g_small_enemies, {
  ["data/entities/animals/drone_shield.xml"] = { ng = 2 },
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
	{
		prob = 0.1,
		entity = "data/entities/animals/weakspirit.xml",
	},
})
