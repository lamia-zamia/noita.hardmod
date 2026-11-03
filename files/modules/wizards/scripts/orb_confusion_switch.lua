local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

local eid = GetUpdatedEntityID()
local active_item = utils.GetInternalInt(eid, "confuse_player_new_active_item", false)

if not active_item or active_item == 0 then return end
utils.SetInternalInt(eid, "confuse_player_new_active_item", 0)

local i2comp = EntityGetFirstComponentIncludingDisabled(eid, "Inventory2Component")
if i2comp then
	ComponentSetValue2(i2comp, "mDontLogNextItemEquip", true)
	ComponentSetValue2(i2comp, "mForceRefresh", true)
	ComponentSetValue2(i2comp, "mActiveItem", active_item)
end
