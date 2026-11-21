local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local owner = GetUpdatedEntityID()
local x, y = EntityGetTransform(owner)

local RADIUS = 220

local nearby_players = EntityGetInRadiusWithTag(x, y, RADIUS, "player_unit")
if nearby_players then
	for i,player in ipairs(nearby_players) do
		if #(EntityGetAllChildren(player, "hardmod_player_tele_disabler") or {}) == 0 then
			EntityAddChild(player, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/anti_tele_effect.xml", x, y))
		end
	end
end
