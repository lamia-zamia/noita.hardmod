local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml
local dir = "mods/noita.hardmod/files/modules/vanilla_bosses/"

for xml in nxml.edit_file("data/entities/animals/boss_wizard/wizard_orb_death.xml") do
	xml:add_child(nxml.new_element("LuaComponent", {
		script_damage_about_to_be_received = dir.."scripts/negate_nonplayer_damage.lua",
	}))
end

for xml in nxml.edit_file("data/entities/animals/boss_wizard/boss_wizard.xml") do
	xml:add_child(nxml.new_element("LuaComponent", {
		script_death = dir.."scripts/boss_wizard_death.lua",
	}))
end

utils.modifile("data/entities/animals/boss_wizard/death.lua", [[EntityLoad( "data/entities/items/pickup/wandstone.xml",  x + 16, y )]], [[--EntityLoad( "data/entities/items/pickup/wandstone.xml",  x + 16, y )]])