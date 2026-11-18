
local entity_id = GetUpdatedEntityID()
EntityAddComponent2(entity_id, "LuaComponent", {
	_tags = "enabled_in_hand",
	script_enabled_changed = "mods/noita.hardmod/files/modules/no_more_instant_recharge/wand_counter_instant_recharge.lua",
	execute_every_n_frame = -1,
})
