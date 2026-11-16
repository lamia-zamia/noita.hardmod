local entity_id = GetUpdatedEntityID()
local root = EntityGetRootEntity(entity_id)

local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local item_effect_index = dofile_once(utils.module_dir.."vanilla_perk_rebalances/scripts/perks/item_effects_data.lua")

local has_amplified_items_perk
for _,child in ipairs(EntityGetAllChildren(root, "perk_entity") or {}) do
	print("c")
	local ui_icon_comp = EntityGetFirstComponentIncludingDisabled(child, "UIIconComponent")
	if ui_icon_comp and ComponentGetValue2(ui_icon_comp, "icon_sprite_file")
			== "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/item_immunities_016.png" then
		print("d")
		has_amplified_items_perk = true
	end
end
if not has_amplified_items_perk then return end

local path = EntityGetFilename(entity_id)
local func = item_effect_index[path]
if not func then return end

func(entity_id, true)