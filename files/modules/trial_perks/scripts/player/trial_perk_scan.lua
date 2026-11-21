local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

local CHALLENGE_PERK_NAMES = "Time Trial,Glass Heart"

local function try_reroll_trial_perks(x, y)
	local nearby_perks = EntityGetInRadiusWithTag(x, y, 500, "perk")
	for _,perk in ipairs(nearby_perks) do
		local perk_id = utils.GetInternalString(perk, "perk_id") or ""
		if perk_id == "HARDMOD_TIME_TRIAL" or perk_id == "HARDMOD_GLASS_HEART" then
			-- delete the trial perk
			local perk_x, perk_y = EntityGetTransform(perk)
			EntityKill(perk)

			-- spawn a new one (does not consider its neighbours so might spawn a duplicate)
			dofile_once("data/scripts/perks/perk.lua")
			perk_spawn_random(perk_x, perk_y)
		end
	end
end

local player_x, player_y = EntityGetTransform(GetUpdatedEntityID())
local nearby_perks = EntityGetWithTag("perk")
if nearby_perks and #nearby_perks > 0 then

	for i,perk_entity_id in ipairs(nearby_perks) do

		local itemcomp = EntityGetComponent(perk_entity_id, "ItemComponent")
		if itemcomp then

			local perk_name = GameTextGetTranslatedOrNot(ComponentGetValue2(itemcomp[1], "item_name"))
			if string.find(CHALLENGE_PERK_NAMES, perk_name) then

				local perk_x, perk_y = EntityGetTransform(perk_entity_id)
				if player_y > perk_y + 130 then
					try_reroll_trial_perks( perk_x, perk_y )
					GamePrint("The '" .. perk_name .. "' perk has been rerolled")
					GamePlaySound("data/audio/Desktop/misc.bank", "game_effect/frozen/damage", player_x, player_y)
				end
			end
		end
	end
end
