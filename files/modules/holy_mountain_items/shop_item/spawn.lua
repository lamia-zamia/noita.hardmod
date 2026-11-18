local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

local shop_items = dofile_once("mods/noita.hardmod/files/modules/holy_mountain_items/shop_item/shop_items.lua")


---@diagnostic disable-next-line: lowercase-global
function hardmod_spawn_purchasable_item(x, y)
	SetRandomSeed(x, y)

	local levels = {
		2,
		5,
		9,
		12,
		16,
		20,
		25,
	}

	local y_chunk_level = math.floor(y/512)
	local hm_level = 0
	for i,stage_boundary in ipairs(levels) do
		if stage_boundary > y_chunk_level then break end
		hm_level = i
	end

	local data = {
		x = x, y = y,
		hm_level = hm_level,
	}

	local item = utils.ConditionalRandomFromTable(shop_items.items, data)
	if not item then return end
	local cost = item.base_cost*1.7^(hm_level-1)

	if hm_level == 7 then
		if not item.hm_escape then item = shop_items.indexed.ring_of_elevation end
		cost = 0
	end --guarantee a way to the previous holy mountain

	local entity = EntityLoad(
		"mods/noita.hardmod/files/modules/holy_mountain_items/entities/shop_item.xml",
		x, y
	)

	EntityAddComponent2(entity, "SpriteComponent", {
		_tags = "enabled_in_world",
		offset_x = item.offset_x or 0,
		offset_y = (item.offset_y or 0)-.05,
		image_file = item.sprite
	})

	EntityAddComponent2(entity, "LuaComponent", {
		script_item_picked_up = "mods/noita.hardmod/files/modules/holy_mountain_items/shop_item/pickup.lua",
		-- I LOVE STORING SHIT IN SCRIPT_PRESSURE_PLATE_CHANGE
		script_pressure_plate_change = item.entity,
		script_biome_entered = item.id,
		remove_after_executed = true,
	})

	if cost > 0 then
		EntityAddComponent2(entity, "ItemCostComponent", { cost = cost })
		EntityAddComponent2(entity, "SpriteComponent", {
			_tags = "shop_cost,enabled_in_world",
			image_file = "data/fonts/font_pixel_white.xml",
			text = tostring(cost),
			offset_x = utils.GetIntegerCostOffsetX(cost) * .5,
			offset_y = 15,
			is_text_sprite = true,
			update_transform = true,
			update_transform_rotation = false,
			z_index = -1,
		})

		EntityAddComponent2(entity, "ItemComponent", {
			_tags = "enabled_in_world",
			item_name = item.name,
			ui_sprite = item.sprite,
			max_child_items = 0,
			is_pickable = true,
			is_equipable_forced = true,
			play_spinning_animation = false,
			preferred_inventory = "QUICK",
		})
	end

	if item.rotate_deg then
		EntitySetTransform(entity, x, y, math.rad(item.rotate_deg))
	end

	if item.generate_func then item:generate_func(entity) end
end
