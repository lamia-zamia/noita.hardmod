local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local owner = GetUpdatedEntityID()
local x, y = EntityGetTransform(owner)

local radius = utils.GetInternalInt(owner, "hardmod_all_seeing_radius") or 115

local nearby_players = EntityGetInRadiusWithTag(x, y, radius, "player_unit")
if not nearby_players or #nearby_players == 0 then return end

local player = nearby_players[1]

local ai_comp = EntityGetFirstComponentIncludingDisabled(owner, "AnimalAIComponent")
if ai_comp and ComponentGetValue2(ai_comp, "ai_state") ~= 15 then
	ComponentSetValue2(ai_comp, "ai_state", 15)
	ComponentSetValue2(ai_comp, "ai_state_timer", GameGetFrameNum() + 300)

	GamePlaySound("data/audio/Desktop/misc.bank", "game_effect/blindness/create", x, y)

	-- make the entity visible through fog of war
	EntityAddChild(owner,
		EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/all_seeing_fow_hole.xml", x, y))

	-- give the player a status over their head
	-- LoadGameEffectEntityTo(player, "mods/noita.hardmod/files/modules/enemy_perks/entities/status_effects/status_spotted.xml")
end
