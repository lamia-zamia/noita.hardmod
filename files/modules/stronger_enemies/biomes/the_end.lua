dofile_once("mods/noita.hardmod/files/modules/stronger_enemies/patcher.lua")

AddEnemies(g_small_enemies, {
	{
		prob = 0.2,
		entity = "data/entities/animals/the_end/spearbot.xml"
	},
	{
		prob = 0.02,
		entity = "data/entities/animals/thundermage_big.xml"
	},
	{
		prob = 0.05,
		entity = "data/entities/animals/the_end/skycrystal_physics.xml"
	},
	{
		prob = 0.004,
		entity = "data/entities/animals/wraith_storm.xml"
	},
	{
		prob = 0.001,
		entity = "data/entities/animals/wraith_glowing.xml"
	},
	{
		prob = 0.02,
		entity = "data/entities/animals/wraith.xml"
	},
	{
		prob = 0.02,
		entity = "data/entities/animals/wraith_glowing.xml"
	},
  	{
		prob = 0.1,
		entity = "data/entities/animals/weakspirit.xml",
	},
})
