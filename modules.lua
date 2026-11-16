---@class module_list
local modules = {
	-- List of all module IDs to load, in order
	index = {
		test_module_dont_run = {
			disabled = true,
		},
		example = {
			disabled = true,
		},
		nerfed_combat_healing = {
			integral = true,
		},
		enemy_perks = {
			integral = true,
		},
		trappier_traps = {},
		cheeseless_triggers = {
			integral = true,
		},
		logo_splash = {},
		starter_wands = {},
		unshuffle = {},
		limited_spells = {
			integral = true,
		},
		vanilla_perk_rebalances = {
			integral = true,
		},
		vanilla_spell_rebalances = {
			integral = true,
		},
		spells_reweighted = {
			integral = true,
		},
		vanilla_quests = {
			integral = true,
		},
		vanilla_bosses = {
			integral = true,
		},
		less_explosive = {},
		holy_mountain_rework = {
			integral = true,
		},
		holy_mountain_items = {},
		no_more_max_hp_cheesing = {
			integral = true,
		},
		phantom_nemesis = {
			integral = true,
		},
		alt_fire_anything = {},
		ending = {
			integral = true,
		},
		credits = {},
		nerf_vanilla_cheeses = {
			integral = true,
		},
		chest_tweaks = {},
		better_anvil = {},
		rapidfire_nerfs = {
			integral = true,
		},
		trial_perks = {},
		biome_map = {
			integral = true,
		},
		biome_modifiers = {
			integral = true,
		},
		stronger_enemies = {
			integral = true,
		},
		potions = {
			integral = true,
		},
		alternate_biomes = {},
		polymorph_gui = {},
		worse_digging = {},
		vanilla_bugfixes = {},
		spell_variety = {},
		haunted_wands = {},
		for_the_worthy = {},
		no_more_instant_recharge = {},
		snail = {},
		greed_curse_rework = {},
	},
	-- `true` to force enable, `false` to force disable
	force_disable_modules = {
		test_module_dont_run = true,
		example = true,
		credits = true,
	},
	list = {},
	integral_list = {},
}

for name,data in pairs(modules.index) do
	if data.disabled then modules.index[name] = nil goto continue end
	data.name = name
	modules.list[#modules.list+1] = name
	if data.integral then modules.integral_list[#modules.integral_list+1] = name end

	::continue::
end

return modules
