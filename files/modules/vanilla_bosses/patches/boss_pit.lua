local hooks = {}
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

ModLuaFileAppend("data/entities/animals/boss_pit/boss_pit_damage.lua", "mods/noita.hardmod/files/modules/vanilla_bosses/appends/boss_pit_damage.lua")
ModLuaFileAppend("data/entities/animals/boss_pit/boss_pit_death.lua", "mods/noita.hardmod/files/modules/vanilla_bosses/appends/boss_pit_death.lua")

utils.patchifile("data/entities/animals/boss_pit/boss_pit_death.lua", {
	{
		from = [[EntityLoad]],
		to = [[-- EntityLoad]]
	},
})

-- hooks.mod_init = function()
-- 	for xml in nxml.edit_file("data/entities/animals/boss_pit/boss_pit.xml") do
-- 		xml:add_child(nxml.new_element("LuaComponent", {
-- 			script_source_file = "mods/noita.hardmod/files/modules/vanilla_bosses/scripts/boss_pit_on_spawn.lua",
-- 			execute_every_n_frame = 1,
-- 			remove_after_executed = true
-- 		}))
-- 	end
-- end

return hooks --Don't forget to do this if you want your changes to apply!!!!
