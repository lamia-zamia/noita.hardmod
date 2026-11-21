local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils
local hooks = {}---@type hooks

-- Note: Part of cheeseless_triggers is handled in core/gun.lua

hooks.mod_init = function()
	ModLuaFileAppend("data/scripts/gun/gun.lua", "mods/noita.hardmod/files/modules/cheeseless_triggers/scripts/gun_payload_cast_delay.lua")
	ModLuaFileAppend( "data/scripts/gun/gun.lua", "mods/noita.hardmod/files/modules/cheeseless_triggers/scripts/gun_append.lua" )
end

utils.modifile(
	"data/entities/animals/boss_wizard/death.lua",
	[[local opts = { "ADD_TRIGGER", "ADD_TIMER", "ADD_DEATH_TRIGGER", "RESET", "DUPLICATE" }]],
	[[local opts = { "RESET", "HARDMOD_SACRILEGE", "DUPLICATE" }]]
)
utils.modifile(
	"data/entities/animals/boss_wizard/death.lua",
	[[for i=1,5 do]],
	[[for i=1,3 do]]
)
utils.modifile(
	"data/entities/animals/boss_wizard/death.lua",
	[[CreateItemActionEntity( opts[i], x - 8 * 4 + (i-1) * 16, y )]],
	[[CreateItemActionEntity( opts[i], x - 8 * 2 + (i-1) * 16, y )]]
)

return hooks
