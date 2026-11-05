local orig_spawn_orb = spawn_orb
function spawn_orb(x, y, ...)
	EntityLoad("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/tinker_orbroom.xml", x, y)
	orig_spawn_orb(x, y, ...)
end
