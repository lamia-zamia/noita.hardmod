local hooks = {}---@type hooks
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

hooks.mod_post_init = function()
	ModLuaFileAppend("data/scripts/gun/gun.lua", "mods/noita.hardmod/files/modules/no_more_instant_recharge/gun_append.lua")
	ModLuaFileAppend("data/scripts/gun/procedural/gun_procedural.lua", "mods/noita.hardmod/files/modules/no_more_instant_recharge/gun_procedural_append.lua")
	ModLuaFileAppend("data/scripts/gun/procedural/gun_procedural_better.lua", "mods/noita.hardmod/files/modules/no_more_instant_recharge/gun_procedural_append.lua")
	ModLuaFileAppend("data/scripts/gun/procedural/starting_wand.lua", "mods/noita.hardmod/files/modules/no_more_instant_recharge/starting_wand_append.lua")
	ModLuaFileAppend("data/scripts/gun/procedural/starting_bomb_wand.lua", "mods/noita.hardmod/files/modules/no_more_instant_recharge/starting_wand_append.lua")
end

return hooks --Don't forget to do this if you want your changes to apply!!!!
