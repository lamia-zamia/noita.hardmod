local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

ModLuaFileAppend("data/scripts/gun/gun.lua", "mods/noita.hardmod/files/modules/core/appends/gun.lua")
ModLuaFileAppend("data/scripts/biome_scripts.lua", "mods/noita.hardmod/files/modules/core/appends/biome_scripts.lua")

-- remove perks with not_progress from progress menu
utils.patchifile("data/scripts/perks/perk_reflect.lua", {{
	from = [[
		RegisterPerk(
			perk.id,
			perk.ui_name,
			perk.ui_description,
			perk.ui_icon,
			perk.perk_icon
		)
	]],
	insert_before = [[
		if not perk.not_progress then
	]],
	insert_after = [[
		end
	]],
}})

if ModIsEnabled("Apotheosis") then
	utils.modifile(
		"mods/Apotheosis/files/scripts/perks/custom_perks.lua",
		[[do c = perk_list[z]],
		[[do local c = perk_list[z]]
	)
end

return {}
