local hooks = {}

-- Note: Part of cheeseless_triggers is handled in core/gun.lua

hooks.mod_init = function()
	ModLuaFileAppend("data/scripts/gun/gun.lua", "mods/noita.hardmod/files/modules/cheeseless_triggers/scripts/gun_payload_cast_delay.lua")
end

return hooks
