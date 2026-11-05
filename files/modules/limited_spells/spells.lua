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

local hooks = {}

hooks.new_spells = {
	{
		id = "HARDMOD_SPELL_INDULGENCE",
		name = "$hardmod_spell_indulgence_name",
		description = "$hardmod_spell_indulgence_desc",
		sprite = "mods/noita.hardmod/files/modules/limited_spells/gfx/indulgence.png",
		type = ACTION_TYPE_OTHER,
		recursive = true,
		spawn_probability = "0",
		spawn_requires_flag = "hardmod_cannot_spawn",
		price = 1000,
		mana = 20,
		action = function()
			if reflecting then return end

			local data = nil
			if #deck > 0 then data = deck[1]
			elseif #hand > 0 then data = hand[1]
			end

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

			local max_uses = get_spell_data(data.id).max_uses or -1
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

			local cost_label = entity_load_at_wand_tip(player, "mods/noita.hardmod/files/modules/limited_spells/entity/indulgence_cost_label.xml")
			if cost_label then
				EntityAddComponent2(cost_label, "VariableStorageComponent", {
					name = "hardmod_indulgence_cast_price",
					value_int = cast_price,
				})
			end
		end,
	},
}

hooks.spell_patches = {
	["BOMB"] = { max_uses = 5 },
	["MINE"] = { max_uses = 20 },
	["GRENADE"] = { max_uses = 30 },
	["GRENADE_TRIGGER"] = { max_uses = 30 },
	["GRENADE_ANTI"] = { max_uses = 30 },
	["ROCKET_TIER_2"] = { max_uses = 10 },
	["ROCKET_TIER_3"] = { max_uses = 10 },

	["FISH"] = { never_unlimited = true, max_uses = 10 },
	["EXPLODING_DEER"] = { never_unlimited = true, max_uses = 5 },
	["EXPLODING_DUCKS"] = { never_unlimited = true, max_uses = 10, mana = 120 },
	["FREEZING_GAZE"] = { max_uses = 10, never_unlimited = true },

	["FIREBALL_RAY_ENEMY"] = { max_uses = 10 },
	["LIGHTNING_RAY_ENEMY"] = { max_uses = 10 },
	["TENTACLE_RAY_ENEMY"] = { max_uses = 10 },
	["WORM_SHOT"] = { max_uses = 5 },
	["HEAL_BULLET"] = { max_uses = 15 },
	["ANTIHEAL"] = { max_uses = 15 },
	["SWARM_FLY"] = { max_uses = 16 },
	["SWARM_FIREBUG"] = { max_uses = 16 },
	["SWARM_WASP"] = { max_uses = 16 },
	["FRIEND_FLY"] = { max_uses = 16 },

	["DARKFLAME"] = { max_uses = -1 },
	["ICEBALL"] = { never_unlimited = true },
	["DAMAGE_FOREVER"] = { max_uses = 0, never_unlimited = true },
	["ALL_DISCS"] = { max_uses = 10, never_unlimited = true },
	["ALL_ACID"] = { max_uses = 10, never_unlimited = true },
	["DIVIDE_10"] = { max_uses = -1 },
}

local never_unlimited = {
	"BLACK_HOLE_BIG", "WHITE_HOLE_BIG", "FREEZING_GAZE", "BOMB_HOLY",
	"PROPANE_TANK", "CRUMBLING_EARTH", "SUMMON_ROCK", "NUKE", "NUKE_GIGA",
	"DESTRUCTION", "MASS_POLYMORPH", "STATIC_TO_SAND", "SHIELD_FIELD", "BERSERK_FIELD",
	"PROJECTILE_TRANSMUTATION_FIELD", "PROJECTILE_THUNDER_FIELD", "VACUUM_LIQUID",
	"TENTACLE_RAY_ENEMY", "LIGHTNING_RAY_ENEMY", "FIREBALL_RAY_ENEMY",
	"ORBIT_NUKES", "CRUMBLING_EARTH_PROJECTILE", "X_RAY",
	"ALL_NUKES", "ALL_ROCKETS", "ALL_DEATHCROSSES", "ALL_BLACKHOLES", "ALL_SPELLS",
	"METEOR_RAIN", "WORM_RAIN",
}

for _,spell in pairs(never_unlimited) do hooks.spell_patches[spell] = { never_unlimited = true } end

local touches = { "TOUCH_GOLD", "TOUCH_WATER", "TOUCH_OIL", "TOUCH_ALCOHOL", "TOUCH_PISS", "TOUCH_GRASS", "TOUCH_BLOOD", "TOUCH_SMOKE" }
for _,spell in pairs(touches) do
	hooks.spell_patches[spell] = {
		never_unlimited = true,
		max_uses = 3,
	}
end

local plicates = { "I_SHOT", "Y_SHOT", "T_SHOT", "W_SHOT", "QUAD_SHOT", "PENTA_SHOT", "HEXA_SHOT" }
for _,spell in pairs(plicates) do
	hooks.spell_patches[spell] = {
		never_unlimited = true,
		max_uses = 16,
	}
end

return hooks
