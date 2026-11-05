local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local polymorphs = {
	POLYMORPH = {
		ui_name = "$hardmod_status_polymorph_name",
		ui_description = "$hardmod_status_polymorph_desc",
		ui_icon = "mods/noita.hardmod/files/modules/polymorph_gui/polymorphed.png",
	},
	POLYMORPH_RANDOM = {
		ui_name = "$hardmod_status_chaotic_polymorph_name",
		ui_description = "$hardmod_status_chaotic_polymorph_desc",
		ui_icon = "mods/noita.hardmod/files/modules/polymorph_gui/chaotic_polymorphed.png",
	},
	POLYMORPH_UNSTABLE = {
		ui_name = "$hardmod_status_unstable_polymorph_name",
		ui_description = "$hardmod_status_unstable_polymorph_desc",
		ui_icon = "mods/noita.hardmod/files/modules/polymorph_gui/chaotic_polymorphed.png",
	},
}

if utils.MatchDateLocal({month = 3, day = 31}) then
	polymorphs.POLYMORPH.ui_description = "$hardmod_status_polymorph_trans_day"
end


---@diagnostic disable-next-line: undefined-global
for _,status_effect in ipairs(status_effects) do
	if polymorphs[status_effect.id] then
		for key,value in pairs(polymorphs[status_effect.id]) do
			status_effect[key] = value
		end
	end
end