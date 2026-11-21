local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local owner = GetUpdatedEntityID()
local x, y = EntityGetTransform(owner)

local RADIUS = 220

local nearby_players = EntityGetInRadiusWithTag(x, y, RADIUS, "player_unit")
if nearby_players then
	for i,player in ipairs(nearby_players) do
		--utils.SetInternalInt(player, "hardmod_anti_tele_last_frame", GameGetFrameNum()) this appears unused?

		if #(EntityGetAllChildren(player, "hardmod_player_tele_disabler") or {}) == 0 then
			EntityAddChild(player, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/anti_tele_effect.xml", x, y))
		end
		-- if string.find(EntityGetFilename(proj), "tele")
		-- or string.find(EntityGetFilename(proj), "blink") then
		-- 	local mWhoShot = ComponentGetValue2(proj_comp, "mWhoShot")
		-- 	if mWhoShot ~= owner then
		-- 		local ox, oy = EntityGetTransform(mWhoShot)

		-- 		-- local nearby_players = EntityGetInRadiusWithTag(x, y, RADIUS, "player_unit")
		-- 		-- if nearby_players and #nearby_players > 0 then
		-- 		EntitySetTransform(proj, ox, oy)
		-- 		EntityKill(proj)
		-- 		-- else if not EntityHasTag(mWhoShot, "player_unit"))
		-- 		-- 	EntityKill(proj)
		-- 		-- end
		-- 	end
		-- end
	end
end
