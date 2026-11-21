-- local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua")---@type nxml
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils
local hooks = {}---@type hooks

utils.patchifile("data/scripts/gun/procedural/level_1_wand.lua", {
	{
		from = [[local total]],
		insert_before = [[
			ComponentObjectSetValue2(ability_comp, "gun_config", "shuffle_deck_when_empty", false)
		
			if fire_rate_wait < 10 then
				ComponentObjectSetValue2(ability_comp, "gunaction_config", "fire_rate_wait", 10)
				fire_rate_wait = 10
			end

			if reload_time < 14 then
				ComponentObjectSetValue2(ability_comp, "gun_config", "reload_time", 14)
				reload_time = 14
			end

		]]
	}
})

function hooks.world_init()
	GlobalsSetValue("PERK_NO_MORE_SHUFFLE_WANDS", "1")
end

return hooks
