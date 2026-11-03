dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

AddEnemies(g_big_enemies, {
  	{
		prob = 0.09,
		entity = "data/entities/animals/weakspirit.xml",
	},
	{
		prob = 0.07,
		entity = "mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_wizard_confusion.xml"
	},
})

PatchEnemies(g_unique_enemy, {
	["data/entities/animals/drone_shield.xml"] = {
		prob = 0.03
	}
})
