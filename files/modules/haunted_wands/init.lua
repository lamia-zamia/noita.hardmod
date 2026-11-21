local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

local hooks = {}

hooks.mod_post_init = function()
	ModLuaFileAppend("data/scripts/gun/procedural/gun_procedural.lua", "mods/noita.hardmod/files/modules/haunted_wands/scripts/gun_procedural_append.lua")
	ModLuaFileAppend("data/scripts/gun/procedural/gun_procedural_better.lua", "mods/noita.hardmod/files/modules/haunted_wands/scripts/gun_procedural_append.lua")
	ModLuaFileAppend("data/scripts/biome_scripts.lua", "mods/noita.hardmod/files/modules/haunted_wands/scripts/biome_scripts_append.lua")
end

-- remove green pickup particles from haunted wands
utils.modifile("data/scripts/particles/wand_pickup.lua",
[[	local entity_id    = GetUpdatedEntityID()]],
[[	local entity_id    = GetUpdatedEntityID()
	if EntityHasTag( entity_id, "hardmod_evil_wand" ) then return end]]
)

-- utils.modifile("data/scripts/gun/procedural/gun_procedural.lua",
-- [[	for k,v in pairs(variables_01) do
-- 		apply_random_variable(gun, v)
-- 	end]],
-- [[	for k,v in pairs(variables_01) do
-- 		apply_random_variable(gun, v)
-- 	end
-- 	p = Random(0, 100)
-- 	if p < 100 then
-- 		local mtp = Random(1.5, 2.0)
-- 		gun["fire_rate_wait"] = (gun["fire_rate_wait"]) / mtp
-- 		gun["reload_time"] = gun["reload_time"] / mtp
-- 		gun["spread_degrees"] = math.max(gun["spread_degrees"], Random(6, 9)) * mtp
-- 	end]]
--)

return hooks --Don't forget to do this if you want your changes to apply!!!!
