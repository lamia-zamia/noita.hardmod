dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

PatchEnemies(g_small_enemies, {
  -- NG+1 makes these guys spawn much more frequently
  ["data/entities/animals/tank_super.xml"] = { ng = 2 },
})

PatchEnemies(g_big_enemies, {
  ["data/entities/animals/drone_shield.xml"] = { ng = 2 },
})

AddEnemies(g_big_enemies, {
	{
		prob = 0.5,
		entity = "data/entities/animals/roboguard.xml"
	},
	-- evil and fucked up spirit coming your way to ruin your explosion immunity
  	{
		prob = 0.2,
		entity = "data/entities/animals/weakspirit.xml",
	},
})
