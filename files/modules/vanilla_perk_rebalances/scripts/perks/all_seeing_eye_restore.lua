local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

EntitySetComponentsWithTagEnabled(GetUpdatedEntityID(), "fog_of_war_hole", true)
GamePrint("Your All-Seeing Eye has been restored.")

local nearby_mobs = EntityGetWithTag("hardmod_master_of_blinding")
if nearby_mobs ~= nil then
	for i,mob in ipairs(nearby_mobs) do
		utils.SetInternalInt(mob, "hardmod_wizard_dark_counter", 0)
	end
end
