local entity_id = GetUpdatedEntityID()
local component = GetUpdatedComponentID() --this returns 0 for NO FUCKING REASON and im going to KILL NOLLA

local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local item_effect_index = dofile_once(utils.module_dir.."vanilla_perk_rebalances/scripts/perks/item_effects_data.lua")

local function update_state()
	local root = EntityGetRootEntity(entity_id)
	print("updating")
	print(entity_id)

	print("a")
	if root == entity_id then return end
	print("b")

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
	print("e")
	if not has_amplified_items_perk then return end
	print("f")

	local path = EntityGetFilename(entity_id)
	local func = item_effect_index[path]
	if not func then return end
	print("g")
	func(entity_id, true)
end

---@diagnostic disable-next-line: lowercase-global
function enabled_changed(item, state)
	print(("enabled changed on frame %s, state: [%s]"):format(GameGetFrameNum(), tostring(state)))
	component = GetUpdatedComponentID()

	print("enabled changed")
	update_state()
	EntitySetComponentIsEnabled(item, component, true)
end