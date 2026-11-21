local hitfx = GetUpdatedEntityID()
local entity = EntityGetRootEntity(hitfx)

if IsPlayer(entity) then EntityKill(hitfx) return end

for _,dmc in pairs(EntityGetComponent(entity, "DamageModelComponent") or {}) do
	local mat = ComponentGetValue2(dmc, "blood_material")
	if mat == "blood_fading" then
		ComponentSetValue2(dmc, "blood_material", "blood")
	end
end

EntityKill(hitfx)
