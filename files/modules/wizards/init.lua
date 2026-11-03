local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

utils.patchifile("data/ui_gfx/animal_icons/_list.txt", {
	{
		from = "wizard_twitchy\n",
		insert_after = "hardmod_wizard_confusion\n"
	}
})

utils.patchifile("data/entities/projectiles/orb_poly.xml", {
	{ from = [[damage="0.3"]], to=[[damage="0"]] },
	{ from = [[damage = "0.1"]], to=[[damage="0"]] },
})

return {
	player_spawned = function()
		EntityLoad("mods/noita.hardmod/files/modules/wizards/entities/hardmod_wizard_confusion.xml", 627, -125)
	end
}
