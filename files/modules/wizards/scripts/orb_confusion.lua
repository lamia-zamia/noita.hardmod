local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

local entity_id = GetUpdatedEntityID()
local eid = EntityGetRootEntity(entity_id)

if not IsPlayer(eid) then
	local effect = GetGameEffectLoadTo(eid, "CONFUSION", true)
    ComponentSetValue2(effect, "frames", 300)

	return
end

local quick
for _,entity in pairs(EntityGetAllChildren(eid) or {}) do
	if EntityGetName(entity) == "inventory_quick" then
		quick = entity
		break
	end
end

if not quick then return end

local i2comp = EntityGetFirstComponentIncludingDisabled(eid, "Inventory2Component")
if i2comp then
	local item = ComponentGetValue2(i2comp, "mActualActiveItem")
	utils.SetInternalInt(eid, "confuse_player_active_item", item)

	ComponentSetValue2(i2comp, "mDontLogNextItemEquip", true)
	ComponentSetValue2(i2comp, "mForceRefresh", true)
	ComponentSetValue2(i2comp, "mActualActiveItem", 0)
end

EntityAddComponent2(eid, "LuaComponent", {
	script_source_file = "mods/noita.hardmod/files/modules/wizards/scripts/orb_confusion_swap.lua",
	execute_every_n_frame = 1,
	remove_after_executed = true,
})
