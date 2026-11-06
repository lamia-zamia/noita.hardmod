---@diagnostic disable: undefined-global

local action_id_table = nil
local function get_spell_data(action_id)
	if not action_id_table then
		action_id_table = {}
		for _,action in pairs(actions) do
			action_id_table[action.id] = action
		end
	end

	return action_id_table[action_id]
end

local function apply_freeze()
	if reflecting then return end

	local player = GetUpdatedEntityID()
	SetRandomSeed(GameGetFrameNum(), 123)
	if Random(1, 5) == 1 then
		local count = GameGetGameEffectCount(player, "INTERNAL_ICE")

		if count > 3 then
			local effect = GetGameEffectLoadTo(player, "FROZEN", true)
			ComponentSetValue2(effect, "lifetime", 100)
		else
			LoadGameEffectEntityTo(player, "mods/noita.hardmod/files/modules/vanilla_spell_rebalances/entities/effect_cold.xml")
		end
	end
end

local hooks = {}

hooks.new_spells = {}

hooks.spell_patches = {
	["BOMB"] = { max_uses = 5 },
	["MINE"] = { max_uses = 20 },
	["GRENADE"] = { max_uses = 30 },

	["ADD_TRIGGER"] = { mana = 88, spawn_level = "10", spawn_probability = "0" },
	["ADD_TIMER"] = { mana = 88, spawn_level = "10", spawn_probability = "0" },
	["ADD_DEATH_TRIGGER"] = { mana = 88, spawn_level = "10", spawn_probability = "0" },
	["SCATTER_2"] = {
		action = function()
			draw_actions(2, true)
			c.spread_degrees = c.spread_degrees + 4.0
		end,
	},
	["SCATTER_3"] = {
		action = function()
			draw_actions(2, true)
			c.spread_degrees = c.spread_degrees + 6.0
		end,
	},
	["SCATTER_4"] = {
		action = function()
			draw_actions(2, true)
			c.spread_degrees = c.spread_degrees + 10.0
		end,
	},
	["SUMMON_WANDGHOST"] = {
		spawn_level = "10",
		spawn_probability = "0.1",
		max_uses = 0,
	},
	["FREEZE"] = {
		mana = 25,
		action = function()
			apply_freeze()
			c.damage_ice_add = c.damage_ice_add + 0.2
			c.game_effect_entities = c.game_effect_entities .. "data/entities/misc/effect_frozen.xml,"
			c.extra_entities = c.extra_entities .. "data/entities/particles/freeze_charge.xml,"
			draw_actions(1, true)
		end
	},
	["FREEZE_FIELD"] = {
		mana = 75,
		max_uses = 3,
		never_unlimited = true,
		action = function()
			apply_freeze()
			add_projectile("data/entities/projectiles/deck/freeze_field.xml")
			c.fire_rate_wait = c.fire_rate_wait + 15
		end
	},
	["POLYMORPH_FIELD"] = { mana = 90, max_uses = 3, never_unlimited = true },
	["ELECTROCUTION_FIELD"] = { mana = 50, max_uses = 10 },
	["CHAOS_POLYMORPH_FIELD"] = { mana = 50 },
	["AREA_DAMAGE"] = { mana = 60 },
	["EXPLOSIVE_PROJECTILE"] = {
		mana = 60,
		action = function ()
			c.explosion_radius = c.explosion_radius + 7.5
			c.damage_explosion_add = c.damage_explosion_add + 0.2
			c.fire_rate_wait = c.fire_rate_wait + 40
			c.speed_multiplier = c.speed_multiplier * 0.75
			shot_effects.recoil_knockback = shot_effects.recoil_knockback + 30.0

			draw_actions(1, true)
		end
	},
	["RESET"] = {
		action = function()
			current_reload_time = current_reload_time - 25

			move_hand_to_discarded()
			for _,v in ipairs(deck) do table.insert(discarded, v) end
			hand = {}
			deck = {}

			if not force_stop_draws then
				force_stop_draws = true
				move_discarded_to_deck()
				order_deck()
			end
		end,
	},
	["LUMINOUS_DRILL"] = {
		mana = 18,
		spawn_level = "2,3,4,5", spawn_probability = "0.3,0.6,0.8,0.8",
		action = function()
			add_projectile("data/entities/projectiles/deck/luminous_drill.xml")
			-- c.friendly_fire = true
			c.fire_rate_wait = c.fire_rate_wait - 16
			current_reload_time = current_reload_time - 8
		end
	},
	["LASER_LUMINOUS_DRILL"] = {
		mana = 25,
		spawn_level = "2,3,4,5", spawn_probability = "0.3,0.6,0.8,0.8",
		action = function()
			add_projectile_trigger_timer("data/entities/projectiles/deck/luminous_drill.xml", 4, 1)
			-- c.friendly_fire = true
			c.fire_rate_wait = c.fire_rate_wait - 16
			current_reload_time = current_reload_time - 8
		end
	},
	["FLAMETHROWER"] = { max_uses = -1 }, -- damage is also changed in damage.lua
	["BUCKSHOT"] = {
		action 		= function()
			add_projectile("data/entities/projectiles/deck/buckshot_player.xml")
			add_projectile("data/entities/projectiles/deck/buckshot_player.xml")
			add_projectile("data/entities/projectiles/deck/buckshot_player.xml")
			c.fire_rate_wait = c.fire_rate_wait + 8
			c.spread_degrees = c.spread_degrees + 6.0
		end,
	},
}

local mats = { "MATERIAL_WATER", "MATERIAL_OIL", "MATERIAL_BLOOD", "MATERIAL_CEMENT", "WATER_TRAIL" }
local crits = { "HITFX_CRITICAL_WATER", "HITFX_CRITICAL_OIL", "HITFX_CRITICAL_BLOOD" }

for _,spell in pairs(mats) do hooks.spell_patches[spell] = { mana = 18 } end
for _,spell in pairs(crits) do hooks.spell_patches[spell] = { mana = 25 } end

local curses = { "CURSE", "CURSE_WITHER_PROJECTILE", "CURSE_WITHER_EXPLOSION", "CURSE_WITHER_MELEE", "CURSE_WITHER_ELECTRICITY" }
for _,spell in pairs(curses) do
	hooks.spell_patches[spell] = {
		max_uses = 16,
		spawn_level = "5,6,10",
		spawn_probability = "0.7,0.7,0.1",
	}
end

local reduce_dmg = {
	HOMING = 0.3,
	HOMING_ACCELERATING = 0.3,
	HOMING_SHORT = 0.2,
	HOMING_ROTATE = 0.2,
	AUTOAIM = 0.2,
}

local add_cd = {
	SPITTER_TIER_3 = 2,
	SPITTER_TIER_3_TIMER = 2,
	BUBBLESHOT = 4,
	BUBBLESHOT_TRIGGER = 4,
	LASER = 11,
	LIFETIME_DOWN = 8,
	NOLLA = 8,
	EXPLOSION_REMOVE = 8,
	HORIZONTAL_ARC = 6,
	LINE_ARC = 4,
	ORBIT_SHOT = 6,
	SPIRALING_SHOT = 6,
	PHASING_ARC = 8,
}

hooks.edit_spell = function(spell)
	if reduce_dmg[spell.id] then
		local orig_action = spell.action
		local amount = reduce_dmg[spell.id]
		spell.action = function(...)
			c.damage_projectile_add = c.damage_projectile_add - amount
			orig_action(...)
		end
	end

	if add_cd[spell.id] then
		local orig_action = spell.action
		local amount = add_cd[spell.id]
		spell.action = function(...)
			c.fire_rate_wait = c.fire_rate_wait + amount
			orig_action(...)
		end
	end
end

return hooks
