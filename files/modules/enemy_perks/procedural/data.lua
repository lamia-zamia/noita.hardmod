local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local dir = utils.module_dir.."enemy_perks/"

local on_hit_callbacks = {
	{
		id = "curser",
		script_on_hit = dir.."scripts/curser_apply.lua"
	}
}