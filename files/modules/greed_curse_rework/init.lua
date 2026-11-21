local hooks = {}---@type hooks
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local dir = utils.module_dir.."greed_curse_rework/"

utils.modifile("data/entities/items/pickup/greed_curse.xml",
	[[script_item_picked_up="data/scripts/magic/greed_curse/greed_curse_pickup.lua"]],
	[[script_item_picked_up="mods/noita.hardmod/files/modules/greed_curse_rework/greed_curse_pickup.lua"]]
)

ModMaterialsFileAdd(dir.."materials.xml")
ModLuaFileAppend("data/scripts/items/__drop_money.lua", dir.."append_drop_money.lua")



return hooks
