local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

function item_pickup(entity_item, entity_who_picked, item_name)
	-- if not EntityHasTag(entity_who_picked, "player_unit") then return end
	if utils.GetInternalInt(entity_item, "hardmod_evil_ghost_spawned") or 0 == 1 then return end
	utils.SetInternalInt(entity_item, "hardmod_evil_ghost_spawned", 1)

	EntityAddComponent2(entity_item, "LuaComponent", {
		_tags = "enabled_in_world,enabled_in_inventory,enabled_in_hand",
		script_source_file = "mods/noita.hardmod/files/modules/haunted_wands/scripts/evil_wand_on_pickup_2.lua",
		execute_on_added = false,
		execute_every_n_frame = 1,
		execute_times = 1,
		remove_after_executed = true,
	})
end
