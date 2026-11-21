
local ability_id = GetUpdatedEntityID()
local host_id = EntityGetParent(ability_id)

local acomp = EntityGetFirstComponentIncludingDisabled(host_id, "AnimalAIComponent")
if acomp then
    ComponentSetValue2(acomp, "attack_dash_enabled", false)
    ComponentSetValue2(acomp, "minimum_knockback_force", 100000)
end
