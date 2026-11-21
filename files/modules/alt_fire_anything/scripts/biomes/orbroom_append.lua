
local _spawn_orb = spawn_orb
function spawn_orb(x, y, ...)
	CreateItemActionEntity("HARDMOD_ALT_FIRE_ANYTHING", x + 30, y + 40)
	return _spawn_orb(x, y, ...)
end
