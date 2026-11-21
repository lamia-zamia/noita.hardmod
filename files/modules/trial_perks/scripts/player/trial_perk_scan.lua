local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

local CHALLENGE_PERK_NAMES = "Time Trial,Glass Heart"

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
					GamePrint("The '" .. perk_name .. "' perk has been destroyed")
					GamePlaySound("data/audio/Desktop/misc.bank", "game_effect/frozen/damage", player_x, player_y)
					EntityKill(perk_entity_id)
				end
			end
		end
	end
end
