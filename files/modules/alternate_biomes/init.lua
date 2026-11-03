local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

local function weighted_choice(options)
	local total = 1.0
	for _, o in ipairs(options) do
		local w = o.weight or 0
		if w > 0 then total = total + w end
	end
	local r = Randomf(0, total)
	if r <= 1.0 then return nil end
	local acc = 1.0
	for _, o in ipairs(options) do
		local w = o.weight or 0
		if w > 0 then
			acc = acc + w
			if r <= acc then return o.biome end
		end
	end
	return nil
end

ModMaterialsFileAdd("mods/noita.hardmod/files/modules/alternate_biomes/materials/materials.xml")

utils.AddEnemyToProgress("hardmod_fungal_longleg", "longleg")

local M = {
	magic_numbers_and_seed_initialised = function() 
		local replacements = dofile_once("mods/noita.hardmod/files/modules/alternate_biomes/biome_list.lua")
		if(GameHasFlagRun("biome_swap_done")) then
			return
		end
		GameAddFlagRun("biome_swap_done")

		local i = 0
		for source_biome, options in pairs(replacements) do
			i = i + 1
			SetRandomSeed(i, i)
			local target = weighted_choice(options)
			if target ~= nil then
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
		end
	end,
}

return M
