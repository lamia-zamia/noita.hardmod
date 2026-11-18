local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils
dofile_once("mods/noita.hardmod/lib/utilities.lua")

local entity_id = GetUpdatedEntityID()
if utils.GetInternalInt(entity_id, "hardmod_sampo_orb_glyph_is_glowing") == 1 then return end

local sprite_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "SpriteComponent")
if sprite_comp ~= nil then
	local glyph_index = utils.GetInternalInt(entity_id, "hardmod_sampo_orb_glyph_index") or 99
	if GameGetOrbCountThisRun() >= glyph_index then
		utils.SetInternalInt(entity_id, "hardmod_sampo_orb_glyph_is_glowing", 1)
		ComponentSetValue2(sprite_comp, "image_file", "mods/noita.hardmod/files/modules/ending/gfx/sampo_orb_indicator_2.png")
	end
end
