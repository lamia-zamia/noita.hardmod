local old_spawn_small_enemies = spawn_small_enemies
---@diagnostic disable-next-line: lowercase-global
function spawn_small_enemies(x, y, ...)
	old_spawn_small_enemies(x-512, y-256, ...)
end
