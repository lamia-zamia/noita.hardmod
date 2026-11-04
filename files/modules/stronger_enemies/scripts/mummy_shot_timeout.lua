local eid = GetUpdatedEntityID()
local aicomp = EntityGetFirstComponent(eid, "AnimalAIComponent")
if not aicomp then return end

ComponentSetValue2(aicomp, "attack_ranged_enabled", true)
