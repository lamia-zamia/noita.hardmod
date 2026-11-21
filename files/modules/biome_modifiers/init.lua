ModLuaFileAppend("data/scripts/biome_modifiers.lua", "mods/noita.hardmod/files/modules/biome_modifiers/modifiers/patch.lua")

local hooks = {}---@type hooks

function hooks.mod_post_init()
	ModLuaFileAppend("data/scripts/biome_modifiers.lua", "mods/noita.hardmod/files/modules/biome_modifiers/modifiers/list.lua")
end

function hooks.player_spawned(player, new_run)
	-- TODO: switch to the new hook
	-- will require changing biome modifier logic cause currently it
	-- has a weird inconsistent system for detecting biomes
	if new_run then
		EntityAddComponent2(player, "LuaComponent", {
			script_biome_entered = "mods/noita.hardmod/files/modules/biome_modifiers/biome_entered.lua",
			execute_every_n_frame = -1
		})
	end
end

return hooks
