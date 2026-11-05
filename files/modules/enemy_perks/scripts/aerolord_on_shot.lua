
function shot(entity_id)
    EntityAddComponent2(entity_id, "LuaComponent", {
    	script_source_file = "mods/noita.hardmod/files/modules/enemy_perks/scripts/aerolord_on_proj_death.lua",
    	execute_every_n_frame = -1,
    	execute_on_removed = true,
    })
end
