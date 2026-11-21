local shop_items = dofile_once("mods/noita.hardmod/files/modules/holy_mountain_items/shop_item/shop_items.lua")

function item_pickup(eid, player)
	local x, y = EntityGetTransform(eid)
	local cid = GetUpdatedComponentID()

	local path = ComponentGetValue2(cid, "script_pressure_plate_change")
	EntityKill(eid)

	if not path or not ModDoesFileExist(path) then
		print("item picked up without actual entity path!!!")
		return
	end

	local item = EntityLoad(path, x, y)

	-- remove vanilla pickup effect on potions and shit
	for _,luacomp in pairs(EntityGetComponentIncludingDisabled(item, "LuaComponent") or {}) do
		local script = ComponentGetValue2(luacomp, "script_item_picked_up")
		if script == "data/scripts/items/potion_effect.lua" then
			EntityRemoveComponent(item, luacomp)
		end
	end

	GamePickUpInventoryItem(player, item, false)
	EntityLoad("data/entities/particles/image_emitters/shop_effect.xml", x, y)

	local shop_item = shop_items.indexed[ComponentGetValue2(cid, "script_biome_entered") or ""]
	if shop_item and shop_item.bought_func then
		local data = {
			player = player,
			x = x, y = y,
		}
		shop_item.bought_func(eid, item, data)
	end
end
