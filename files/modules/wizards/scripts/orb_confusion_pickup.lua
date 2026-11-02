local eid = GetUpdatedEntityID()

local vsc
for _,comp in pairs(EntityGetComponent(eid, "VariableStorageComponent") or {}) do
	if ComponentGetValue2(comp, "name") == "player_item_ids" then
		vsc = comp
		break
	end
end

if not vsc then return end

---@type string
local value = ComponentGetValue2(vsc, "value_string")
EntityRemoveComponent(eid, vsc)

local items = {}

for item in value:gmatch("[^,]+") do
	local id = tonumber(item)
	if id then
		table.insert(items, id)
	end
end

local i2comp = EntityGetFirstComponentIncludingDisabled(eid, "Inventory2Component")
if i2comp then
	ComponentSetValue2(i2comp, "mDontLogNextItemEquip", true)
	ComponentSetValue2(i2comp, "mActualActiveItem", 0)
	ComponentSetValue2(i2comp, "mForceRefresh", true)
end

for _,item in pairs(items) do
	GamePickUpInventoryItem(eid, item, false)
	EntityAddTag(item, "enabled_in_world")
end
