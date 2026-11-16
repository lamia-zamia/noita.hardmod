---@diagnostic disable: undefined-global

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

hooks.new_spells = {
	{
		id = "HARDMOD_TORCH_MAGIC",
		name = "$hardmod_spell_torch_magic_name",
		description = "$hardmod_spell_torch_magic_desc",
		sprite = "mods/noita.hardmod/files/modules/vanilla_spell_rebalances/gfx/ui_gfx/spells/magic_torch.png",
		type = ACTION_TYPE_PASSIVE,
		spawn_level = "5,6,10",
		spawn_probability = "0.8,0.6,0.4",
		price = 200,
		mana = 8,
		custom_xml_file = "mods/noita.hardmod/files/modules/vanilla_spell_rebalances/entities/cards/card_torch_magic.xml",
		action = function()
			draw_actions( 1, true )
		end,
	},
}

hooks.spell_patches = {
	["BOMB"] = { max_uses = 5 },
	["MINE"] = { max_uses = 20 },
	["GRENADE"] = { max_uses = 30 },
	["TELEPORT_CAST"] = {
		mana = 200,
		max_uses = 10,
		never_unlimited = true,
		spawn_level = "10",
		spawn_probability = "0"
	},
	["ADD_TRIGGER"] = { mana = 88, spawn_level = "10", spawn_probability = "0" },
	["ADD_TIMER"] = { mana = 88, spawn_level = "10", spawn_probability = "0" },
	["ADD_DEATH_TRIGGER"] = { mana = 88, spawn_level = "10", spawn_probability = "0" },
	["PIERCING_SHOT"] = {
		spawn_level = "5,6", -- PIERCING_SHOT
		spawn_probability = "0.5,0.4", -- PIERCING_SHOT
		-- name = "$hardmod_spell_piercing_shot_name",
        -- description = "$hardmod_spell_piercing_shot_desc",
		action = function()
			-- local entity = "mods/noita.hardmod/files/modules/vanilla_spell_rebalances/entities/piercing_shot_tracker.xml,"
            -- if not c.extra_entities:find(entity) then
            --     c.extra_entities = c.extra_entities .. entity
            -- end

            c.extra_entities = c.extra_entities .. "data/entities/misc/piercing_shot.xml,mods/noita.hardmod/files/modules/vanilla_spell_rebalances/entities/piercing_shot_init.xml,"
			c.damage_projectile_add = c.damage_projectile_add - 0.4
			c.friendly_fire = true
            draw_actions(1, true)
        end
	},
	["SCATTER_2"] = {
		action = function()
			draw_actions(2, true)
			c.spread_degrees = c.spread_degrees + 4.0
		end,
	},
	["SCATTER_3"] = {
		action = function()
			draw_actions(3, true)
			c.spread_degrees = c.spread_degrees + 6.0
		end,
	},
	["SCATTER_4"] = {
		action = function()
			draw_actions(4, true)
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
			c.fire_rate_wait = c.fire_rate_wait + 30
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
	["DARKFLAME"] = {
		sprite = "mods/noita.hardmod/files/modules/vanilla_spell_rebalances/gfx/ui_gfx/spells/darkflame_player.png",
		max_uses = -1,
		custom_xml_file = "mods/noita.hardmod/files/modules/vanilla_spell_rebalances/entities/card_darkflame_player.xml",
		action = function()
			add_projectile("mods/noita.hardmod/files/modules/vanilla_spell_rebalances/entities/darkflame_player.xml")
			c.fire_rate_wait = c.fire_rate_wait + 20
		end,
	},
	["FLAMETHROWER"] = { -- damage is also changed in damage.lua
		mana = 15,
		max_uses = -1,
		action = function()
			add_projectile("data/entities/projectiles/deck/flamethrower.xml")
			c.fire_rate_wait = c.fire_rate_wait - 8
			c.spread_degrees = c.spread_degrees + 4.0
		end,
	},
	["BUCKSHOT"] = {
		action 		= function()
			add_projectile("data/entities/projectiles/deck/buckshot_player.xml")
			add_projectile("data/entities/projectiles/deck/buckshot_player.xml")
			add_projectile("data/entities/projectiles/deck/buckshot_player.xml")
			c.fire_rate_wait = c.fire_rate_wait + 8
			c.spread_degrees = c.spread_degrees + 6.0
		end,
	},
	["LASER_EMITTER"] = { mana = 80 },
	["LASER_EMITTER_CUTTER"] = { mana = 80 },
	["LASER_EMITTER_FOUR"] = { mana = 120 },
	["ORBIT_LASERS"] = { mana = 140, max_uses = 5 },
	["ARROW"] = {
		action = function()
			add_projectile("data/entities/projectiles/deck/arrow.xml")
			c.fire_rate_wait = c.fire_rate_wait + 10
			c.spread_degrees = c.spread_degrees - 8
			c.damage_critical_chance = c.damage_critical_chance + 7
			shot_effects.recoil_knockback = 15.0
		end,
	},
	["HEAL_BULLET"] = { indulgence_price = 250 },
	["SPELLS_TO_POWER"] = { spawn_level = "10", spawn_probability = "0.5" },
	["BOMB_DETONATOR"] = {
		mana = 100,
		max_uses = 20,
		never_unlimited = true,
		action = function()
			c.fire_rate_wait = c.fire_rate_wait + 60
			add_projectile( "data/entities/projectiles/deck/bomb_detonator.xml" )
		end,
		-- 	if reflecting then return end

		-- 	local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" )
		-- 	local prev_cast_frame = utils.GetInternalInt( GetUpdatedEntityID(), "hardmod_bomb_detonator_prev_cast_frame" ) or 0
		-- 	local current_frame = GameGetFrameNum()
		-- 	local x, y = EntityGetTransform( GetUpdatedEntityID() )
		-- 	if current_frame - prev_cast_frame > 30 then
		-- 		add_projectile( "data/entities/projectiles/deck/bomb_detonator.xml" )
		-- 		GamePlaySound( "data/audio/Desktop/misc.bank", "misc/beam_from_sky_kick", x, y )
		-- 		utils.SetInternalInt( GetUpdatedEntityID(), "hardmod_bomb_detonator_prev_cast_frame", current_frame )
		-- 	else
        --         GamePlaySound( "data/audio/Desktop/items.bank", "magic_wand/not_enough_mana_for_action", x, y )
        --         add_projectile( "data/entities/projectiles/deck/fizzle.xml" )
		-- 	end
		-- end,
	},
	["TORCH"] = {
		custom_xml_file = "mods/noita.hardmod/files/modules/vanilla_spell_rebalances/entities/cards/card_torch.xml",
	},
	["TORCH_ELECTRIC"] = {
		mana = -2,
		custom_xml_file = "mods/noita.hardmod/files/modules/vanilla_spell_rebalances/entities/cards/card_torch_electric.xml",
	},
}

local mats = { "MATERIAL_WATER", "MATERIAL_OIL", "MATERIAL_BLOOD", "MATERIAL_CEMENT", "WATER_TRAIL" }
local crits = { "HITFX_CRITICAL_WATER", "HITFX_CRITICAL_OIL", "HITFX_CRITICAL_BLOOD" }

for _,spell in pairs(mats) do hooks.spell_patches[spell] = { mana = 7 } end
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
