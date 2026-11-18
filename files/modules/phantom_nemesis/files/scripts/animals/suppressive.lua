
local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent(entity_id)

local comp = EntityGetFirstComponentIncludingDisabled(parent_id, "AnimalAIComponent")
if comp then
	local aspd = ComponentGetValue2(comp, "attack_ranged_frames_between")
	ComponentSetValue2(comp, "attack_ranged_frames_between", math.max(1, math.floor(aspd/4)))
end

local aicomps = EntityGetComponentIncludingDisabled(parent_id, "AIAttackComponent") or {}
if #aicomps < 1 then return end
for k=1,#aicomps do
    local v = aicomps[k]
    local aspd = ComponentGetValue2(v, "frames_between")
    ComponentSetValue2(v, "frames_between", math.max(1, math.floor(aspd/4)))

    local qwef = ComponentGetValue2(v, "frames_between_global")
    ComponentSetValue2(v, "frames_between_global", math.max(1, math.floor(qwef/4)))
end
