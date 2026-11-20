return {
	spell_patches = {
		["MATTER_EATER"] = {
			mana = 60,
			max_uses = -1,
			never_unlimited = false,
		},
		["BLACK_HOLE"] = {
			spawn_level = "4,5,6,10",
			spawn_probability = "0.7,0.7,0.8,1",
		},
		["BLACK_HOLE_DEATH_TRIGGER"] = {
			spawn_level = "4,5,6,10",
			spawn_probability = "0.7,0.7,0.8,1",
		},
		["WHITE_HOLE"] = {
			spawn_level = "5,6,10",
			spawn_probability = "0.2,0.3,0.5",
		},
	}
}
