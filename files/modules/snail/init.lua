local hooks = {}---@type hooks

function hooks.pre_update(frame)
	if frame % 30 == 0 then dofile("mods/noita.hardmod/files/modules/snail/scripts/spawn_snail.lua") end
end

return hooks
