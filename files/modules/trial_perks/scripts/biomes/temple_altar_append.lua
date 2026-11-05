
local _spawn_hp = spawn_hp
function spawn_hp( x, y )
	_spawn_hp( x, y )
	EntityLoad( "mods/noita.hardmod/files/modules/trial_perks/entities/perks/trial_perk_finish.xml", x - 200, y + 20 )
end
