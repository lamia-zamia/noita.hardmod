local entity_id = EntityGetRootEntity(GetUpdatedEntityID())
local x, y = EntityGetTransform(entity_id)

EntityAddComponent2(entity_id, "LuaComponent", {
    script_damage_received="mods/noita.hardmod/files/modules/phantom_nemesis/files/scripts/animals/shield_reactive_logic.lua",
    limit_how_many_times_per_frame=1,
    execute_every_n_frame=-1
})

EntityAddComponent2(entity_id, "VariableStorageComponent", {
	name="shield_colour",
	value_string="red",
	value_int=-10000
})

EntityKill(GetUpdatedEntityID())
