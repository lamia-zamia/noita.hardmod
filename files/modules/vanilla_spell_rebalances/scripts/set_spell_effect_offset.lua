function enabled_changed(entity_id, is_enabled)
	if not is_enabled then return end

	EntityAddComponent2(entity_id, "LuaComponent", {
		_tags = "enabled_in_hand",
		script_source_file="mods/noita.hardmod/files/modules/vanilla_spell_rebalances/scripts/enable_in_hand_components.lua",
		remove_after_executed = true
	})

	local itx_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "InheritTransformComponent")
	if not itx_comp then return end
	local wand_entity = EntityGetParent(entity_id)
	if not wand_entity or not EntityHasTag(wand_entity, "wand") then return end
	local hs_comp = EntityGetFirstComponentIncludingDisabled(wand_entity, "HotspotComponent")
	if not hs_comp then return end
	local spr_comp = EntityGetFirstComponentIncludingDisabled(wand_entity, "SpriteComponent")
	if not spr_comp then return end

	local hs_x,hs_y = ComponentGetValue2(hs_comp, "offset")
	local spr_x,spr_y = ComponentGetValue2(spr_comp, "offset_x"),ComponentGetValue2(spr_comp, "offset_y")
	local _,_,_w,_h,_r = ComponentGetValue2(itx_comp, "Transform")
	ComponentSetValue2(itx_comp, "Transform",
		hs_x + spr_x - 1,
		hs_y + spr_y,
		_w, _h, _r
	) -- -1 makes it align just a bit more nicely
end