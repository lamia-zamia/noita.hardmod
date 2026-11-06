local _spawn_all_shopitems = spawn_all_shopitems
function spawn_all_shopitems(x, y)
	_spawn_all_shopitems(x, y)
	EntityLoad("mods/noita.hardmod/files/modules/limited_spells/entities/misc/indulgence_spawner.xml", x + 64, y)
end
