local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

local eid = GetUpdatedEntityID()
local x, y = EntityGetTransform(eid)
SetRandomSeed(GameGetFrameNum(), 123)

local vsc
for _,comp in pairs(EntityGetComponent(eid, "VariableStorageComponent") or {}) do
	if ComponentGetValue2(comp, "name") == "confuse_player_item_ids" then
		vsc = comp
		break
	end
end

if not vsc then return end

---@type string
local value = ComponentGetValue2(vsc, "value_string")
local active_item = utils.GetInternalInt(eid, "confuse_player_active_item", false) or 0

EntityRemoveComponent(eid, vsc)

local items = {}
local swap_to = {}

for item in value:gmatch("[^,]+") do
	local id = tonumber(item)
	if id then
		table.insert(items, id)

		---@diagnostic disable-next-line: param-type-mismatch
		if id ~= active_item and EntityHasTag(id, "wand") then
			table.insert(swap_to, id)
		end
	end
end

local i2comp = EntityGetFirstComponentIncludingDisabled(eid, "Inventory2Component")
if i2comp then
	ComponentSetValue2(i2comp, "mDontLogNextItemEquip", true)
	ComponentSetValue2(i2comp, "mForceRefresh", true)
	ComponentSetValue2(i2comp, "mActiveItem", 0)
	ComponentSetValue2(i2comp, "mActualActiveItem", 0)

	if #swap_to > 1 then
		local item = swap_to[Random(1, #swap_to)]
		utils.SetInternalInt(eid, "confuse_player_new_active_item", item)
	end
end

for _,item in pairs(items) do
	if i2comp then ComponentSetValue2(i2comp, "mDontLogNextItemEquip", true) end
	GamePickUpInventoryItem(eid, item, false)
	EntityAddTag(item, "enabled_in_world")
end

GamePrint("$hardmod_log_confused")
GamePlaySound("data/audio/Desktop/items.bank", "magic_wand/mana_fully_recharged", x, y)

EntityAddComponent2(eid, "LuaComponent", {
	script_source_file = "mods/noita.hardmod/files/modules/wizards/scripts/orb_confusion_switch.lua",
	execute_every_n_frame = 1,
	remove_after_executed = true,
})
