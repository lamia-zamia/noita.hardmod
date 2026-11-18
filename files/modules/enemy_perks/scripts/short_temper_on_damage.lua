function damage_received(damage, desc, entity_who_caused, is_fatal)
	local owner = GetUpdatedEntityID()
	if EntityHasTag(entity_who_caused, "player_unit") then
		LoadGameEffectEntityTo(owner, "mods/noita.hardmod/files/modules/enemy_perks/entities/short_temper_berserk.xml")

		local rapidfire_entity = EntityCreateNew("hardmod.short_temper")
		EntityAddComponent2(rapidfire_entity, "LuaComponent", {
			script_source_file = "mods/noita.hardmod/files/modules/enemy_perks/scripts/short_temper_effect_init.lua",
			execute_on_added = true,
			remove_after_executed = true,
		})
		EntityAddComponent2(rapidfire_entity, "LifetimeComponent", { lifetime = 360 })
		EntityAddComponent2(rapidfire_entity, "LuaComponent", {
			script_source_file = "mods/noita.hardmod/files/modules/enemy_perks/scripts/short_temper_effect_end.lua",
			execute_every_n_frame = -1,
			execute_on_removed = true,
		})
		EntityAddChild(owner, rapidfire_entity)
	end
end
