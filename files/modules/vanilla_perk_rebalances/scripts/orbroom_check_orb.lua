local eid = GetUpdatedEntityID()
local x, y = EntityGetTransform(eid)

local entities = EntityGetInRadius(x, y, 64)

for _,entity in pairs(entities) do
	local comp = EntityGetFirstComponentIncludingDisabled(entity, "OrbComponent")
	if comp then return end
end

for _,entity in ipairs(EntityGetInRadius(x, y, 200)) do
	if EntityGetFilename(entity) == "data/entities/particles/gold_dust.xml" then
		EntityKill(entity)
	end
end

print("orb gone")
EntityKill(eid)
