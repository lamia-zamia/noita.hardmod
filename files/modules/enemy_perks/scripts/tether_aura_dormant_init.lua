local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local aura = GetUpdatedEntityID()
local owner = EntityGetRootEntity(aura)
if utils.GetInternalInt(owner, "hardmod_tether_stacks") == 2 then
	EntitySetComponentsWithTagEnabled(aura, "tether_trigger_aura", false)
end
