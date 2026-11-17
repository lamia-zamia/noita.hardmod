local entity_id = GetUpdatedEntityID()
local x,y = EntityGetTransform(entity_id)

local largest_radius = 0
for _,proj_comp in ipairs(EntityGetComponent(entity_id, "ProjectileComponent") or {}) do
	largest_radius = math.max(largest_radius, ComponentObjectGetValue2(proj_comp, "config_explosion", "explosion_radius"))
end

for _,entity in ipairs(EntityGetInRadiusWithTag(x, y, largest_radius, "mortal")) do
	local ex,ey = EntityGetTransform(entity)
	if not RaytraceSurfaces(x, y, ex,ey) then
		EntityAddChild(entity, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/%ID%_apply.xml", ex, ey))
	end
end