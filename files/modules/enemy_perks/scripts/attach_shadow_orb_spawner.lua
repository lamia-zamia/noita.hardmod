EntityAddComponent2(GetUpdatedEntityID(), "LuaComponent", {
	script_source_file = "mods/noita.hardmod/files/modules/enemy_perks/scripts/update_self_perk_list.lua",
	execute_every_n_frame = 150,
	script_death = "mods/noita.hardmod/files/modules/enemy_perks/scripts/spawn_shadow_revive_orb.lua",
	mNextExecutionTime = GameGetFrameNum()+1
})