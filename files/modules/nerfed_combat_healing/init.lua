local hooks = {}---@type hooks
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml
local dir = "mods/noita.hardmod/files/modules/nerfed_combat_healing/"

hooks.mod_init = function()
	for xml in nxml.edit_file("data/entities/player_base.xml") do
		xml:add_child(nxml.new_element("LuaComponent", {
			script_damage_received = dir.."wound_on_damage.lua",
		}))
	end
end


local items_that_remove_status = {
	"data/entities/items/pickup/heart_fullhp_temple.xml",
	"data/entities/items/pickup/heart_fullhp.xml",
}

local negate_healblock = nxml.new_element("LuaComponent", {
	script_item_picked_up = dir.."remove_healblock.lua",
	execute_every_n_frame = "-1"
})

for _,path in ipairs(items_that_remove_status) do
	for xml in nxml.edit_file(path) do
		xml:add_child(negate_healblock)
	end
end

return hooks --Don't forget to do this if you want your changes to apply!!!!
