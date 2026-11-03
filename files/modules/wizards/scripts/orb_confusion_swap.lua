local eid = GetUpdatedEntityID()
local quick
for _,entity in pairs(EntityGetAllChildren(eid) or {}) do
	if EntityGetName(entity) == "inventory_quick" then
		quick = entity
		break
	end
end

if not quick then return end

local items = EntityGetAllChildren(quick) or {}

for _,item in pairs(items) do
	EntityRemoveTag(item, "enabled_in_world")
end

local i2comp = EntityGetFirstComponentIncludingDisabled(eid, "Inventory2Component")
if i2comp then
	ComponentSetValue2(i2comp, "mDontLogNextItemEquip", true)
end

GameDropAllItems(eid)

for _,item in pairs(items) do
	local comp = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent")
	if comp and EntityHasTag(item, "wand") then
		local slot_x, slot_y = ComponentGetValue2(comp, "inventory_slot")

		ComponentSetValue2(comp, "inventory_slot", 3 - slot_x, slot_y)
	end
end

EntityAddComponent2(eid, "VariableStorageComponent", {
	name = "confuse_player_item_ids",
	value_string = table.concat(items, ",")
})

EntityAddComponent2(eid, "LuaComponent", {
	script_source_file = "mods/noita.hardmod/files/modules/wizards/scripts/orb_confusion_pickup.lua",
	execute_every_n_frame = 1,
	remove_after_executed = true,
})
