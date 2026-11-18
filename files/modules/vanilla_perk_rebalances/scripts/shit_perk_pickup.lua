function item_pickup(item, taker, name)
	local entity_id = GetUpdatedEntityID()
	local x, y = EntityGetTransform(entity_id)
	local self_path = ComponentGetValue2(GetUpdatedComponentID(), "script_item_picked_up")

	--GamePlaySound("data/audio/Desktop/misc.bank", "game_effect/invisibility/deactivate", x, y)
	GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/chest_bad", x, y)

	for _,perk in ipairs(EntityGetInRadiusWithTag(x, y, 1000, "item_perk")) do
		if perk == entity_id then goto continue end
		for _,luacomp in ipairs(EntityGetComponent(perk, "LuaComponent") or {}) do
			if ComponentGetValue2(luacomp, "script_item_picked_up") == self_path then
				local px, py = EntityGetTransform(perk)
				EntityLoad("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/shit_perk_destroyed.xml", px, py)
				EntityKill(perk)
				goto continue
			end
		end
		::continue::
	end
end
