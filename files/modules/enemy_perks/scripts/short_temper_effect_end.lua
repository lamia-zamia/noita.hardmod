
local owner = GetUpdatedEntityID()
if owner == nil then return end

local ai_comp = EntityGetFirstComponentIncludingDisabled(owner, "AnimalAIComponent")
if ai_comp then
	local fire_rate = ComponentGetValue2(ai_comp, "attack_ranged_frames_between")
	if fire_rate then
		ComponentSetValue2(ai_comp, "attack_ranged_frames_between", fire_rate * 2)
	end
end
local attack_comps = EntityGetComponentIncludingDisabled(owner,"AIAttackComponent") or {}
for z=1,#attack_comps do
    local attack_comp = attack_comps[z]
    ComponentSetValue2(attack_comp, "frames_between", ComponentGetValue2(attack_comp, "frames_between") * 2)
    ComponentSetValue2(attack_comp, "frames_between_global", ComponentGetValue2(attack_comp, "frames_between_global") * 2)
    ComponentSetValue2(attack_comp, "attack_ranged_aim_rotation_speed", ComponentGetValue2(attack_comp, "attack_ranged_aim_rotation_speed") * 0.5)
end
