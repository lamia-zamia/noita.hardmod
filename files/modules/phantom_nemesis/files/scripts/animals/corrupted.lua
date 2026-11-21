
dofile_once("mods/noita.hardmod/files/modules/phantom_nemesis/files/scripts/magic/proj_pools.lua")

local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent(entity_id)
local pos_x, pos_y = EntityGetTransform(parent_id)
local attack_file = pickrandomspell(pos_x, pos_y)

local comp = EntityGetFirstComponentIncludingDisabled(parent_id, "AnimalAIComponent")
if comp then
	ComponentSetValue2(comp, "attack_ranged_entity_file", attack_file)
	ComponentSetValue2(comp, "attack_ranged_enabled", true)
end

local aicomps = EntityGetComponentIncludingDisabled(parent_id, "AIAttackComponent") or {}
if #aicomps < 1 then return end
for k=1, #aicomps do
    local v = aicomps[k]
    ComponentSetValue2(v, "attack_ranged_entity_file", attack_file)
end
