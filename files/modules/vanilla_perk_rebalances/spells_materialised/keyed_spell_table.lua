---@diagnostic disable:undefined-global

if not actions then
	dofile_once("data/scripts/gun/gun_enums.lua")
	dofile_once("data/scripts/gun/gun_actions.lua")
end

local spells = {}
for _,action in ipairs(actions) do spells[action.id] = action end

return spells
