dofile_once("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/scripts/perks/wand_experimenter/shared.lua")

local wand = GetUpdatedEntityID()
local comp = GetUpdatedComponentID()

local state = GetStoredWandState(wand)
local new_state = GetNewWandState(wand)

if IsWandStateInvalid(state, new_state) then
  EntityRemoveComponent(wand, comp)
  MarkWandAsTinkered(wand)
end

if not state then
	StoreWandState(wand, new_state)
end
