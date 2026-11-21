--This is just a module to test the init hook system.

---@type hooks
local hooks = {
	--Game/World Initialising
	mod_pre_init = {},
	mod_init = {},
	mod_post_init = {},
	magic_numbers_and_seed_initialised = {}, --OnMagicNumbersAndWorldSeedInitialised
	edit_material = {}, --iterates over all materials OnMagicNumbersAndWorldSeedInitialised
	edit_reaction = {}, --iterates over all reactions OnMagicNumbersAndWorldSeedInitialised
	biome_config = {},
	world_init = {},

	--Runtime hooks
	pre_update = {}, --beginning of every frame
	new_eid = {}, --new entity
	post_update = {}, --end of every frame

	--Player hooks
	player_spawned = {}, --When the player spawns in after world is initialised
	player_changed = {}, --Runs whenever polymorphing/unpolymorphing
	player_destroyed = {}, --OnPlayerDied

	--Pause hooks
	mod_settings_changed = {},
	pause_pre_update = {},
	pause_changed = {},
	count_secrets = {},
}

for hook_name,_ in pairs(hooks) do
	---@diagnostic disable-next-line: assign-type-mismatch
	hooks[hook_name] = function(...)
		if ... ~= nil then
			local vals = {...}
			for i,v in ipairs(vals) do
				vals[i] = tostring(v)
			end
			print(("[%s]: (%s)"):format(hook_name, table.concat(vals, ", ")))
		else
			print(("[%s]"):format(hook_name))
		end
		return ...
	end
end

print("raw init")

return hooks
