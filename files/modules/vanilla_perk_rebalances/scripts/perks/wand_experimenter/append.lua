local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

dofile_once("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/scripts/perks/wand_experimenter/shared.lua")
dofile_once("data/scripts/game_helpers.lua")

-- 69 heal for non-shufflers (as per vanilla)
local heal_amounts = { 1.2, 0.6, 0.36, 0.24, 0.16, 0.12, 0.08 }

function wand_fired(wand)
	if not wand then return end

	local player = EntityGetRootEntity(GetUpdatedEntityID())
	if not player or not IsPlayer(player) then return end

	local state = GetStoredWandState(wand)
	local new_state = GetNewWandState(wand)

	-- Nuh uh!
	if not state or IsWandStateInvalid(state, new_state) then
		return
	end

	local comp = EntityGetFirstComponentIncludingDisabled(wand, "AbilityComponent")
	if not comp then return end

	local casts = tonumber(ComponentGetValue2(comp, "stat_times_player_has_shot")) or 0

	if casts > #heal_amounts then
		MarkWandAsTinkered(wand)
		return
	end

	local hp = utils.EntityGetHp(player)

	if GameGetGameEffect(player, "NO_HEAL") ~= 0 or hp and hp.hp >= hp.max_hp then
		local x, y = EntityGetTransform(player)
		GamePlaySound("data/audio/Desktop/misc.bank", "collision/barrel_water/destroy", x, y)
		ComponentSetValue2(comp, "stat_times_player_has_shot", casts - 1)
		return
	end

	local heal_by = heal_amounts[casts]

	heal_entity(player, heal_by)
end
