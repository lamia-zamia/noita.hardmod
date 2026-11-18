
local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent(entity_id)

local animal_ai_comp = EntityGetFirstComponentIncludingDisabled(parent_id,"AnimalAIComponent")
if not animal_ai_comp then return end
local aspd = ComponentGetValue2(animal_ai_comp,"attack_ranged_frames_between")
ComponentSetValue2(animal_ai_comp,"attack_ranged_frames_between",math.max(1,math.floor(aspd*8)))

local aicomps = EntityGetComponentIncludingDisabled(parent_id,"AIAttackComponent") or {}
if #aicomps < 1 then return end
for k=1,#aicomps do
    local v = aicomps[k]
    local zxcv = ComponentGetValue2(v,"frames_between")
    ComponentSetValue2(v,"frames_between",math.max(1,math.floor(zxcv*6)))

    local qwef = ComponentGetValue2(v,"frames_between_global")
    ComponentSetValue2(v,"frames_between_global",math.max(1,math.floor(qwef*6)))
end
