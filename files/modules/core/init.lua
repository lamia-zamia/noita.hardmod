local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

-- remove perks with not_progress from progress menu
utils.modifile("data/scripts/perks/perk_reflect.lua",
[[	RegisterPerk( 
		perk.id,
		perk.ui_name,
		perk.ui_description,
		perk.ui_icon,
		perk.perk_icon
		)]],
[[	if not perk.not_progress then RegisterPerk( 
		perk.id,
		perk.ui_name,
		perk.ui_description,
		perk.ui_icon,
		perk.perk_icon
		) end]]
)

if ModIsEnabled("Apotheosis") then
	utils.modifile("mods/Apotheosis/files/scripts/perks/custom_perks.lua", 'do c = perk_list[z]', 'do local c = perk_list[z]')
end