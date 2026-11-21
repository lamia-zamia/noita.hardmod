dofile_once("mods/noita.hardmod/files/modules/trial_perks/scripts/trial_perk_utils.lua")
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local x, y = EntityGetTransform(GetUpdatedEntityID())

local function finish_time_trial(player)
	AddFlagPersistent("hardmod_time_trial_passed")
	GlobalsSetValue("hardmod_time_trial_start_y", "0")

	local px, py = EntityGetTransform(player)

	GamePrintImportant(GameTextGetTranslatedOrNot("$hardmod_perk_time_trial_msg_pass"))
	EntityLoad("data/entities/particles/image_emitters/perk_effect.xml", x, y)
	GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/chest/create", x, y)

	local game_effect = EntityGetAllChildren(player, "hardmod_time_trial_game_effect")[1]
	if game_effect then
		local effect_comp = EntityGetFirstComponentIncludingDisabled(game_effect, "GameEffectComponent")
		if effect_comp then
			local frames_left = ComponentGetValue2(effect_comp, "frames")
			local tier = 1
			if frames_left >= 2700 then tier = 3
			elseif frames_left <= 1800 then tier = 2 end

			EntityLoad("mods/noita.hardmod/files/modules/trial_perks/entities/props/chest_time_trial_t"..tier..".xml", x, y)
		end
	end

	utils.EntityRemoveAllByTag(player, "hardmod_time_trial")
	SwapPerkIconForSpent(player, "$hardmod_perk_time_trial_name", true)
end

local function finish_glass_heart(player)
	AddFlagPersistent("hardmod_glass_heart_passed")
	GlobalsSetValue("hardmod_glass_heart_start_y", "0")

	local px, py = EntityGetTransform(player)

	-- double the player's max HP
	local dmg_comp = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
		if dmg_comp then
		local p_hp = ComponentGetValue2(dmg_comp, "hp")
		local p_max_hp = ComponentGetValue2(dmg_comp, "max_hp")
		ComponentSetValue2(dmg_comp, "max_hp", p_max_hp * 2)
		GamePrintImportant("$hardmod_perk_glass_heart_msg_pass")
		EntityLoad("data/entities/particles/image_emitters/heart_fullhp_effect.xml", px, py)
	end

	-- spawn the glass chest
	EntityLoad("data/entities/particles/image_emitters/perk_effect.xml", x, y)
	GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/chest/create", x, y)
	EntityLoad("mods/noita.hardmod/files/modules/trial_perks/entities/props/chest_glass_heart_t3.xml", x, y)

	-- final stuff
	utils.EntityRemoveAllByTag(player, "hardmod_glass_heart")
	SwapPerkIconForSpent(player, "$hardmod_perk_glass_heart_name", true)
	GlobalsSetValue("hardmod_glass_heart_start_y", "0")
end

local spawn_return_portal = false
local nearby_players = EntityGetInRadiusWithTag(x, y, 100, "player_unit")
if nearby_players then
	for i,player in ipairs(nearby_players) do
		-- check for Glass Heart
		local start_y = tonumber(GlobalsGetValue("hardmod_glass_heart_start_y")) or 0
		if start_y ~= 0 and (y - start_y) > 600 then
			finish_glass_heart(player)
			spawn_return_portal = true
		end

		-- check for Time Trial
		start_y = tonumber(GlobalsGetValue("hardmod_time_trial_start_y")) or 0
		if start_y ~= 0 and (y - start_y) > 600 then
			finish_time_trial(player)
			spawn_return_portal = true
		end
	end
end
