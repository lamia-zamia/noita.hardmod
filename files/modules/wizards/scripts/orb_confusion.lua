local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

local hitfx = GetUpdatedEntityID()
local comp = GetUpdatedComponentID()
local player = EntityGetRootEntity(hitfx)

local x, y = EntityGetTransform(player)

---@type integer
local state = ComponentGetValue2(comp, "mTimesExecuted")
print("script state "..state)

local function die()
	print("fucking DYING")
	EntityRemoveComponent(hitfx, comp)
	EntityKill(hitfx)
end

if not IsPlayer(player) then
	local effect = GetGameEffectLoadTo(player, "CONFUSION", true)
    ComponentSetValue2(effect, "frames", 300)
	return die()
end

local quick
for _,entity in pairs(EntityGetAllChildren(player) or {}) do
	if EntityGetName(entity) == "inventory_quick" then
		quick = entity
		break
	end
end

if not quick then return die() end

local i2comp = EntityGetFirstComponentIncludingDisabled(player, "Inventory2Component")
if i2comp then
	ComponentSetValue2(i2comp, "mDontLogNextItemEquip", true)

	if state == 0 then
		local item = ComponentGetValue2(i2comp, "mActualActiveItem")
		utils.SetInternalInt(player, "confuse_player_active_item", item)
	end

	if state < 3 then
		ComponentSetValue2(i2comp, "mForceRefresh", true)
		ComponentSetValue2(i2comp, "mActiveItem", 0)
	end
end

if state == 1 then
	local items = EntityGetAllChildren(quick) or {}
	local list = table.concat(items, ",")

	for _,item in pairs(items) do
		EntityRemoveTag(item, "enabled_in_world")
	end

	GameDropAllItems(player)

	for _,item in pairs(items) do
		local icomp = EntityGetFirstComponentIncludingDisabled(item, "ItemComponent")
		if icomp and EntityHasTag(item, "wand") then
			local slot_x, slot_y = ComponentGetValue2(icomp, "inventory_slot")

			ComponentSetValue2(icomp, "inventory_slot", 3 - slot_x, slot_y)
		end
	end

	-- ULTRA JANK
	ComponentSetValue2(comp, "script_biome_entered", list)
end

if state == 2 then
	local value = ComponentGetValue2(comp, "script_biome_entered")
	local active_item = utils.GetInternalInt(player, "confuse_player_active_item", false) or 0

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

	if #swap_to > 1 then
		local item = swap_to[Random(1, #swap_to)]
		utils.SetInternalInt(player, "confuse_player_new_active_item", item)
	end

	for _,item in pairs(items) do
		if i2comp then ComponentSetValue2(i2comp, "mDontLogNextItemEquip", true) end
		GamePickUpInventoryItem(player, item, false)
		EntityAddTag(item, "enabled_in_world")
	end

	GamePrint("$hardmod_log_confused")
	GamePlaySound("data/audio/Desktop/items.bank", "magic_wand/mana_fully_recharged", x, y)
end

if state == 4 then
	local item = utils.GetInternalInt(player, "confuse_player_new_active_item", false)
	utils.SetInternalInt(player, "confuse_player_new_active_item", 0)

	if i2comp and item and item ~= 0 then
		ComponentSetValue2(i2comp, "mForceRefresh", true)
		ComponentSetValue2(i2comp, "mActiveItem", item)
	end
end

if state >= 4 then
	die()
end
