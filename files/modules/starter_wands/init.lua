local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

local proc = "data/scripts/gun/procedural/"
local starting_wand = proc.."starting_wand.lua"
local starting_bomb_wand = proc.."starting_bomb_wand.lua"

utils.patchifile(starting_wand, {
	{
		from = "local mana_max",
		insert_before = [[
			gun.deck_capacity = {3,4}
			gun.actions = { "LIGHT_BULLET", "SPITTER", "BOUNCY_ORB" }
		]]
	},
	{
		from = "math.min(Random(1,3)",
		to = "math.min(Random(2,3)"
	},
	-- makes all possible projs have an even chance to generate
	{ from = "( Random(1,100) < 50 )", to = "( true)" }
})

utils.patchifile(starting_bomb_wand, {
	{
		from = "local mana_max",
		insert_before = [[
			gun.mana_charge_speed = {17, 20}
			gun.shuffle_deck_when_empty = 0
			gun.deck_capacity = 2
		]]
	},
	{ from = "( Random(1,100) < 50 )", to = "( true)" }
})

ModTextFileSetContent(proc.."starting_wand_daily.lua", 'dofile("'..starting_wand..'")')
ModTextFileSetContent(proc.."starting_bomb_wand_daily.lua", 'dofile("'..starting_bomb_wand..'")')
