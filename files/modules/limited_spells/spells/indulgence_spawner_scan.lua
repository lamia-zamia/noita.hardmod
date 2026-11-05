local INDULGENCE_COST = 1000

local x, y = EntityGetTransform(GetUpdatedEntityID())

local purchases_left = 0
local nearby_card_actions = EntityGetInRadiusWithTag(x, y, 128, "card_action")
if nearby_card_actions ~= nil then
	for _,card_action in pairs(nearby_card_actions) do
		local cost_comp = EntityGetFirstComponentIncludingDisabled(card_action, "ItemCostComponent")
		if cost_comp ~= nil then
			purchases_left = purchases_left + 1
		end
	end
end

local nearby_wands = EntityGetInRadiusWithTag(x, y, 128, "wand")
if nearby_wands ~= nil then
	for _,wand in pairs(nearby_wands) do
		local cost_comp = EntityGetFirstComponentIncludingDisabled(wand, "ItemCostComponent")
		if cost_comp ~= nil then
			purchases_left = purchases_left + 1
		end
	end
end

if purchases_left == 0 and EntityGetInRadiusWithTag(x, y, 128, "player_unit")[1] ~= nil then
	local sx, sy = x + 88, y
	EntityLoad("mods/noita.hardmod/files/modules/limited_spells/entity/indulgence_emitter.xml", sx, sy)
	GamePlaySound("data/audio/Desktop/projectiles.snd", "player_projectiles/crumbling_earth/create", sx, sy )

	local indulgence = CreateItemActionEntity("HARDMOD_SPELL_INDULGENCE", sx, sy)
	EntityAddComponent2(indulgence, "ItemCostComponent", {
		_tags = "shop_cost,enabled_in_world",
		cost = INDULGENCE_COST,
		stealable = true
	})

	EntityAddComponent2(indulgence, "LuaComponent", {
		script_item_picked_up = "data/scripts/items/shop_effect.lua",
	})

	-- show the cost
	local offsetx = 6
	local text = tostring(INDULGENCE_COST)
	local textwidth = 0
	for i=1,#text do
		local l = string.sub(text, i, i)

		if l ~= "1" then textwidth = textwidth + 6
		else textwidth = textwidth + 3 end
	end
	offsetx = textwidth * 0.5 - 0.5
	EntityAddComponent2(indulgence, "SpriteComponent", {
		_tags = "shop_cost,enabled_in_world",
		image_file = "data/fonts/font_pixel_white.xml",
		is_text_sprite = true,
		offset_x = offsetx,
		offset_y = 25,
		update_transform = true,
		update_transform_rotation = false,
		text = tostring(INDULGENCE_COST),
		z_index = -1,
	})

	EntityKill(GetUpdatedEntityID())
end
