local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local function inject_into_shop(spell_id, x, y, radius)
	local indexed_gun_actions = dofile_once("mods/noita.hardmod/lib/gun_actions_indexed.lua")
	radius = radius or 300

	local shop_items = {}
	local nearby_spells = EntityGetInRadiusWithTag(x, y, radius, "card_action")
	local nearby_wands = EntityGetInRadiusWithTag(x, y, radius, "wand")
	for _,item in ipairs(nearby_spells) do
		local cost_component = EntityGetFirstComponent(item, "ItemCostComponent")
		if cost_component then
			shop_items[#shop_items+1] = {item, cost_component, true}
		end
	end
	for _,item in ipairs(nearby_wands) do
		if EntityGetFirstComponent(item, "ItemCostComponent") then
			local ability_component = EntityGetFirstComponentIncludingDisabled(item, "AbilityComponent")
			if not ability_component then goto continue end

			local spells = EntityGetAllChildren(item, "card_action") or {}
			shop_items[#shop_items+1] = {item, spells, false}
			--if ability_component and ComponentObjectGetValue2(ability_component, "gun_config", "deck_capacity") < #(spells) then end
		end
		::continue::
	end

	SetRandomSeed(y+286, x+9147)
	local trnd = Random(1, #shop_items)
	local target = shop_items[trnd]
	if target[3] then
		--IF SPELL
		local sx, sy = EntityGetTransform(target[1])
		local cost = ComponentGetValue2(target[2], "cost")
		local eid = CreateItemActionEntity(spell_id, sx, sy)
		EntityAddComponent2(eid, "ItemCostComponent", {
            _tags = "shop_cost,enabled_in_world",
			cost = cost,
			stealable = ComponentGetValue2(target[2], "stealable"),
		})

		EntityAddComponent2(eid, "SpriteComponent", {
			_tags = "shop_cost,enabled_in_world",
			image_file = "data/fonts/font_pixel_white.xml",
			is_text_sprite = true,
			offset_x = utils.GetIntegerCostOffsetX(cost),
			offset_y = 25,
			update_transform = true,
			update_transform_rotation = false,
			text = tostring(cost),
			z_index = -1,
		})

		EntityKill(target[1])
	else
		--IF WAND
		local wx,wy = EntityGetTransform(target[1])
		local spells = {}
		for _,spell in ipairs(target[2]) do
			local itemaction_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemActionComponent")
			if itemaction_comp then
				local wspell_id = ComponentGetValue2(itemaction_comp, "action_id")
				if indexed_gun_actions[wspell_id].type == ACTION_TYPE_PROJECTILE then
					spells[wspell_id] = spells[wspell_id] or {}
					spells[wspell_id][#spells[wspell_id]+1] = spell
				end
			end
		end
		if spells[spell_id] then return end --if wand already has spell then dont bother

		local _spells = {}
		for _,t in pairs(spells) do
			_spells[#_spells+1] = t
		end

		for _,spell_eid in ipairs(_spells[Random(1, #_spells)]) do
			EntityKill(spell_eid)
			local spell = CreateItemActionEntity(spell_id, wx, wy)
			EntityAddChild(target[1], spell)
			EntitySetComponentsWithTagEnabled(spell, "enabled_in_world", false)
		end
	end
end

return function(x, y)
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

	if hm_level == 6 then
		inject_into_shop("SUMMON_EGG", x, y)
	elseif hm_level == 7 then
		inject_into_shop("TELEPORT_PROJECTILE_SHORT", x, y)
	end
end
