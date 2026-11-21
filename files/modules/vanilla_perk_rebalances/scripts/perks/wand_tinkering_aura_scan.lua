dofile_once("mods/noita.hardmod/lib/utilities.lua")

local x, y = EntityGetTransform(GetUpdatedEntityID())
local was_wand_taken = true
local nearby_wands = EntityGetInRadiusWithTag(x, y, 14, "pedestal_wand")
if nearby_wands ~= nil then
	for i,wand_id in ipairs(nearby_wands) do
		local itemcomp = EntityGetFirstComponent(wand_id, "ItemComponent")
		if itemcomp ~= nil and not ComponentGetValue2(itemcomp, "has_been_picked_by_player") then
			was_wand_taken = false
		end
	end
end

if was_wand_taken then
	local nearest_player = EntityGetInRadiusWithTag(x, y, 28, "player_unit")[1]
	if nearest_player == nil then
		GamePlaySound("data/audio/Desktop/projectiles.bank", "player_projectiles/shield/deactivate", x, y)
		EntityKill(GetUpdatedEntityID())
	end
end
