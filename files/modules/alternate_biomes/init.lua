local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils
local list = dofile_once("mods/noita.hardmod/files/modules/alternate_biomes/biome_list.lua")

ModMaterialsFileAdd("mods/noita.hardmod/files/modules/alternate_biomes/materials/materials.xml")
ModLuaFileAppend("mods/noita.hardmod/lib/biome_index.lua",
	"mods/noita.hardmod/files/modules/alternate_biomes/scripts/append_biomes_to_index.lua"
)

utils.AddEnemyToProgress("hardmod_fungal_longleg", "longleg")

local M = {
	magic_numbers_and_seed_initialised = function() 
		if(GameHasFlagRun("hardmod_biome_swap_done")) then
			return
		end
		GameAddFlagRun("hardmod_biome_swap_done")

		local replacements = list.get_replacements()

		for source_biome, target in pairs(replacements) do
			-- if path contains .xml treat it as a full path
			local from_path = "data/biome/" .. source_biome .. ".xml"
			if string.find(source_biome, "%.xml") then
				from_path = source_biome
			end
			local to_path = "mods/noita.hardmod/files/modules/alternate_biomes/biomes/" .. target .. ".xml"
			local to_xml = ModTextFileGetContent(to_path)
			if to_xml then
				ModTextFileSetContent(from_path, to_xml)
				print("Replaced biome " .. from_path .. " with " .. to_path)
			end
		end
	end,
}

return M