local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local item_effect_index = dofile_once(utils.module_dir.."vanilla_perk_rebalances/scripts/perks/item_effects_data.lua")

local function update_state()
	local entity_id = GetUpdatedEntityID()
	local root = EntityGetRootEntity(entity_id)
	if root == entity_id then return end

	local has_amplified_items_perk
	for _,child in ipairs(EntityGetAllChildren(root, "perk_entity") or {}) do
		local ui_icon_comp = EntityGetFirstComponentIncludingDisabled(child, "UIIconComponent")
		if ui_icon_comp and ComponentGetValue2(ui_icon_comp, "icon_sprite_file")
				== "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/item_immunities_016.png" then
			has_amplified_items_perk = true
		end
	end
	if not has_amplified_items_perk then return end

	local path = EntityGetFilename(entity_id)
	local func = item_effect_index[path]
	if not func then return end
	func(entity_id, true)
end

---@diagnostic disable-next-line: lowercase-global
function enabled_changed(item, state)
	if state == true then return end
	update_state()
	EntitySetComponentIsEnabled(item, GetUpdatedComponentID(), true)
end