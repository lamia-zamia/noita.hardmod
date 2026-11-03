local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

utils.AddEnemyToProgress("hardmod_wizard_confusion", "wizard_twitchy")

utils.patchifile("data/entities/projectiles/orb_poly.xml", {
	{ from = [[damage="0.3"]], to=[[damage="0"]] },
	{ from = [[damage = "0.1"]], to=[[damage="0"]] },
})

return {
	player_spawned = function()
		EntityLoad("mods/noita.hardmod/files/modules/wizards/entities/hardmod_wizard_confusion.xml", 627, -125)
	end
}
