---@diagnostic disable: undefined-global

MaxBiomeModifierCount = { default = 5 }
BiomeModifierChances = {
	default = 0.3,
	coalmine = 0.2,
	excavationsite = 0.15,
	fungiforest = 0.4,
}

PatchModifiers({
	SHIELDED = { probability = 0.08 },
	PERFORATED = { probability = 0.1 },
	HOT = { probability = 0.5 },
	FREEZING = { probability = 0.4 },
	FREEZING_COSMETIC = { ui_name = "$hardmod_biomemodifier_freezing" },
	MOIST = {
		remove_from_biomes = { "excavationsite" },
	},
	CONDUCTIVE = {
		probability = 0.08,
		remove_from_biomes = { "coalmine", "snowcastle", "wizardcave" },
	},
	FOG_OF_WAR_REAPPEARS = {
		ui_name = "$hardmod_biomemodifier_darkness",
		probability = 0,
	},
	PLANT_INFESTED = {
		remove_from_biomes = { "coalmine", "coalmine_alt" },
	},
	FOG_OF_WAR_CLEAR_AT_PLAYER = {
		ui_name = "$hardmod_biomemodifier_gloomy"
	},
	SPOOKY = {
		inject_spawns_action = function()
			-- mostly a copy paste just to adjust confusion spirit's spawn chance
			InjectSpawns({
				{ to = g_props, prob = 1.0, entity = "data/entities/buildings/biome_modifiers/tiny_ghost_spawner.xml" },
				{ to = g_props2, prob = 1.0, entity = "data/entities/buildings/biome_modifiers/tiny_ghost_spawner.xml" },
				{ to = g_lamp, prob = 0.2, entity = "data/entities/buildings/biome_modifiers/tiny_ghost_spawner.xml" },
				{ to = g_props, prob = 1.0, entity = "data/entities/props/furniture_tombstone_01.xml" },
				{ to = g_props, prob = 1.0, entity = "data/entities/props/furniture_tombstone_02.xml" },
				{ to = g_props, prob = 1.0, entity = "data/entities/props/furniture_tombstone_03.xml" },
				{ to = g_small_enemies, prob = 0.05, entity = "data/entities/animals/berserkspirit.xml" },
				{ to = g_small_enemies, prob = 0.05, entity = "data/entities/animals/slimespirit.xml" },
				{ to = g_small_enemies, prob = 0.02, entity = "data/entities/animals/confusespirit.xml" },
				{ to = g_small_enemies, prob = 0.02, entity = "data/entities/animals/weakspirit.xml" },
			})
		end,
	},
	INVISIBILITY = { probability = 0.05 },
	PROTECTION_FIELDS = { probability = 0.03 },
	OMINOUS = { probability = 0.02 },
})

AddBiomeGroup({ "wizardcave", "alchemist_secret" })
AddBiomeGroup({ "sandcave" })
AddBiomeGroup({ "rainforest_dark" })
AddBiomeGroup({ "fungiforest" })
AddBiomeGroup({ "meat" })

ForcedBiomeModifiers.wandcave = nil
ForcedBiomeModifiers.wizardcave = nil
ForcedBiomeModifiers.alchemist_secret = nil

-- Was FREEZING, but hell no, that's just lag and inconvenience
ForcedBiomeModifiers.snowcave = "FREEZING_COSMETIC"
