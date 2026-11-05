local eid = GetUpdatedEntityID()
local x, y = EntityGetTransform(eid)

local entities = EntityGetInRadius(x, y, 64)

for _,entity in pairs(entities) do
	local comp = EntityGetFirstComponentIncludingDisabled(entity, "OrbComponent")
	if comp then return end
end

print("orb gone")
EntityKill(eid)
