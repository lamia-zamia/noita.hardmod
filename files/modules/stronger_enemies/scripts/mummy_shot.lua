function shot(eid)
	local proj = EntityGetFirstComponentIncludingDisabled(eid, "ProjectileComponent")
	if not proj then return end

	local shooter = ComponentGetValue2(proj, "mWhoShot")
	if not shooter or IsPlayer(shooter) then return end

	local aicomp = EntityGetFirstComponent(shooter, "AnimalAIComponent")
	if not aicomp then return end

	ComponentSetValue2(aicomp, "attack_ranged_enabled", false)
	EntityAddComponent2(shooter, "LuaComponent", {
		script_source_file = "mods/noita.hardmod/files/modules/stronger_enemies/scripts/mummy_shot_timeout.lua",
		execute_every_n_frame = 80,
		remove_after_executed = true,
	})
end
