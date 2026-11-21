local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local RADIUS = 100

local aura_dormant = GetUpdatedEntityID()
local owner = EntityGetRootEntity(aura_dormant)
local x, y = EntityGetTransform(owner)

local nearest_player = EntityGetInRadiusWithTag(x, y, RADIUS, "player_unit")[1]
if nearest_player then
	local px, py = EntityGetTransform(nearest_player)

	EntityAddChild(owner, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/tether_aura_active.xml", x, y))
	GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/rune/create", px, py)

	-- make the tethering enemy visible through fog of war
	if (utils.GetInternalInt(owner, "has_fow_hole") or 0) == 0 then
		utils.SetInternalInt(owner, "has_fow_hole", 1)
		EntityAddChild(owner, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/all_seeing_fow_hole.xml", x, y))
	end

	EntityKill(aura_dormant)
end
