local eid = EntityGetRootEntity(GetUpdatedEntityID())

if not eid or eid == 0 then return end

for _,name in pairs({ "ProjectileComponent", "LifetimeComponent" }) do
	for _,comp in pairs(EntityGetComponent(eid, name) or {}) do
		local lifetime = ComponentGetValue2(comp, "lifetime")
		if type(lifetime) == "number" then
			ComponentSetValue2(comp, "lifetime", lifetime / 2)
		end
	end
end
