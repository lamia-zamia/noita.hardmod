dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

PatchEnemies(g_small_enemies, {
	["data/entities/animals/thundermage.xml"] = { prob = 0.03 },
	["data/entities/animals/icemage.xml"] = { prob = 0.1 },
	["data/entities/animals/wizard_poly.xml"] = { prob = 0.02 },
	["data/entities/animals/wizard_homing.xml"] = { prob = 0.04 },
	["data/entities/animals/wizard_neutral.xml"] = { prob = 0.04 },
})

PatchEnemies(g_big_enemies, {
	["data/entities/animals/thundermage.xml"] = { prob = 0.06 },
})

PatchEnemiesWithGroups(g_big_enemies, {
	["data/entities/animals/wizard_poly.xml"] = { prob = 0.02 },
	["data/entities/animals/wizard_homing.xml"] = { prob = 0.05 },
	["data/entities/animals/wizard_neutral.xml"] = { prob = 0.05 },
})

AddEnemies(g_small_enemies, {
	{
		prob = 0.1,
		entity = "mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_wizard_confusion.xml",
	}
})

AddEnemies(g_big_enemies, {
	{
		prob = 0.02,
		entity = "data/entities/animals/thundermage_big.xml"
	},
	{
		prob = 0.15,
		entity = "data/entities/animals/weakspirit.xml",
	},
	{
		prob = 0.1,
		entities = {
			"data/entities/animals/wizard_twitchy.xml",
			"mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_wizard_confusion.xml",
		}
	},
	{
		prob = 0.1,
		entities = {
			"mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_wizard_confusion.xml",
			"data/entities/animals/wizard_swapper.xml",
		}
	},
	{
		prob = 0.09,
		-- this is to compensate for these two groups with wizard_poly getting changed to 0.02
		entities = {
			"data/entities/animals/wizard_dark.xml",
			"data/entities/animals/wizard_swapper.xml"
		},
	},
})
