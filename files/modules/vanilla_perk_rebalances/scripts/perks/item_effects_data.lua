local function func_toggle_item_gameeffects(game_effects)
	if type(game_effects) == "string" then
		game_effects = { [game_effects] = true }
	end

	return function(item, togglestate)
		for _,gec in ipairs(EntityGetComponentIncludingDisabled(item, "GameEffectComponent") or {}) do
			if game_effects[ComponentGetValue2(gec, "effect")] then
				EntitySetComponentIsEnabled(item, gec, togglestate)
			end
		end
	end
end

local function func_toggle_item_children(children_names)
	if type(children_names) == "string" then
		children_names = { [children_names] = true }
	end

	return function(item, togglestate)
		for _,child in ipairs(EntityGetAllChildren(item) or {}) do
			if children_names[EntityGetName(child)] then
				for _,comp in ipairs(EntityGetAllComponents(child)) do
					EntitySetComponentIsEnabled(child, comp, togglestate)
				end
			end
		end
	end
end

local effect_items = {
	["data/entities/items/pickup/brimstone.xml"] = func_toggle_item_gameeffects("PROTECTION_FIRE"),
	["data/entities/items/pickup/waterstone.xml"] = func_toggle_item_gameeffects("BREATH_UNDERWATER"),
	["data/entities/items/pickup/thunderstone.xml"] = func_toggle_item_gameeffects("PROTECTION_ELECTRICITY"),
	--["data/entities/items/pickup/stonestone.xml"] = {}, --no effect associated at present
	["mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/items/cheese.xml"] = func_toggle_item_gameeffects("PROTECTION_MELEE"),
	["data/entities/items/pickup/sun/sunseed.xml"] = func_toggle_item_children("hardmod.all_seeing_eye"),
	["data/entities/items/pickup/sun/sunstone.xml"] = func_toggle_item_children("hardmod.all_seeing_eye"),
	["data/entities/items/pickup/evil_eye.xml"] = function(item, state)
		EntitySetComponentsWithTagEnabled(item, "magic_eye_check", true)
	end
}

return effect_items --separate file for cachine