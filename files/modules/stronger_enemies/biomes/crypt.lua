dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

PatchEnemies(g_small_enemies, {
	["data/entities/animals/wizard_homing.xml"] = { prob = 0.05 },
})

PatchEnemies(g_big_enemies, {
	["data/entities/animals/crypt/thundermage.xml"] = { prob = 0.1 },
	["data/entities/animals/crypt/wizard_poly.xml"] = { prob = 0.05 },
	["data/entities/animals/crypt/wizard_tele.xml"] = { prob = 0.05 },
})

AddEnemies(g_small_enemies, {
	{
		prob = 0.07,
		entity = "mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_wizard_confusion.xml"
	},
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
	{
		prob = 0.15,
		entity = "mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_wizard_confusion.xml"
	},
})
