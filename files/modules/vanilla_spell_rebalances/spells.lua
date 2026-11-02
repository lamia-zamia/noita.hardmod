---@diagnostic disable: undefined-global

local action_id_table = nil
local function get_actions_lua_data(action_id)
	if not action_id_table then
		action_id_table = {}
		dofile_once("data/scripts/gun/gun_actions.lua")
		for _,action in pairs(actions) do
			action_id_table[action.id] = action
		end
	end

	return action_id_table[action_id]
end

local function entity_is_wand(entity_id)
	local acomp = EntityGetFirstComponentIncludingDisabled(entity_id, "AbilityComponent")
	if not acomp then return false end
	return ComponentGetValue2(acomp, "use_gun_script") == true
end

local function get_held_wand(entity_id)
	if entity_id ~= nil then
		local inv2_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "Inventory2Component")
		if not inv2_comp then return end
		local active_item = ComponentGetValue2(inv2_comp, "mActiveItem")
		if entity_is_wand(active_item) then
			return active_item
		end
	end
end

local function entity_load_at_wand_tip(player_entity_id, load_this_entity)
	local wand_entity_id = get_held_wand(player_entity_id)
	if not player_entity_id or not wand_entity_id then return end

	local ctrl_comp = EntityGetFirstComponent(player_entity_id, "ControlsComponent")
	local hs_comp = EntityGetFirstComponentIncludingDisabled(wand_entity_id, "HotspotComponent")
	if ctrl_comp ~= nil and hs_comp ~= nil then
		local aim_x, aim_y = ComponentGetValue2(ctrl_comp, "mAimingVectorNormalized")
		local offset_x, offset_y = ComponentGetValue2(hs_comp, "offset")
		local offset_mag = math.sqrt(offset_x ^ 2 + offset_y ^ 2)

		local wx, wy = EntityGetTransform(wand_entity_id)
		local tx = wx + (offset_mag * aim_x)
		local ty = wy + (offset_mag * aim_y)
		return EntityLoad(load_this_entity, tx, ty)
	end

	return nil
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

local hooks = {
	new_spells = {
		{
			id = "HARDMOD_SPELL_INDULGENCE",
			name = "$hardmod_spell_indulgence_name",
			description = "$hardmod_spell_indulgence_desc",
			sprite = "mods/noita.hardmod/files/modules/vanilla_spell_rebalances/gfx/spells/indulgence.png",
			type = ACTION_TYPE_OTHER,
			recursive = true,
			spawn_probability = "0",
			spawn_requires_flag = "hardmod_cannot_spawn",
			price = 1000,
			mana = 20,
			action = function()
				if reflecting then return end

				local data = {}
				if #deck > 0 then data = deck[1]
				elseif #hand > 0 then data = hand[1]
				else data = nil end

				local rec = check_recursion(data, recursion_level)
				if not data or rec < 0 or data.uses_remaining > 0 then
					mana = mana + 40
					draw_actions(1, true)
					return
				end

				local player = GetUpdatedEntityID()
				local wcomp = EntityGetFirstComponent(player, "WalletComponent")
				if wcomp == nil then return end
				local money = ComponentGetValue2(wcomp, "money")

				local max_uses = get_actions_lua_data(data.id).max_uses or -1
				local cast_price = 10

				if data.id == "DIVIDE_10" then cast_price = 500
				elseif max_uses <= 2 or data.recursive then cast_price = 250
				elseif max_uses <= 5 then cast_price = 125
				elseif max_uses <= 10 then cast_price = 50
				elseif max_uses <= 20 then cast_price = 25
				end

				local x, y = EntityGetTransform(GetUpdatedEntityID())
				if money < cast_price then
					GamePlaySound("data/audio/Desktop/items.bank", "magic_wand/out_of_mana", x, y)
					GamePrint(
						GameTextGet(
							"$hardmod_spell_indulgence_not_enough",
							GameTextGetTranslatedOrNot(data.name), tostring(cast_price)
						)
					)

					return
				end

				ComponentSetValue2(wcomp, "money", money - cast_price)

				data.action(rec)
				mana = mana - data.mana

				GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/goldnugget/create", x, y)

				local cost_label = entity_load_at_wand_tip(player, "mods/noita.hardmod/files/modules/vanilla_spell_rebalances/entities/indulgence_cost_label.xml")
				if cost_label then
					EntityAddComponent2(cost_label, "VariableStorageComponent", {
						name = "hardmod_indulgence_cast_price",
						value_int = cast_price,
					})
				end
			end,
		},
	},
	spell_patches = {
		["BOMB"] = { max_uses = 5 },
		["MINE"] = { max_uses = 20 },
		["GRENADE"] = { max_uses = 30 },
		["TELEPORT_PROJECTILE"] = { mana = 20 },
		["TELEPORT_PROJECTILE_SHORT"] = { mana = 30 },
		["ALPHA"] = { mana = 80 },
		["GAMMA"] = { mana = 80 },
		["TAU"] = { mana = 120 },
		["SIGMA"] = { mana = 90 },
		["MU"] = { mana = 90 },
		["ELECTRIC_CHARGE"] = { mana = 15 },
		["SUMMON_WANDGHOST"] = {
			spawn_level = "10",
			spawn_probability = "0.1",
			max_uses = 0,
		},
		["FREEZE"] = {
			mana = 20,
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
			action = function ()
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
	}
}

local reduce_dmg = {
	HOMING = 0.3,
	HOMING_SHORT = 0.2,
	HOMING_ROTATE = 0.2,
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
end

return hooks
