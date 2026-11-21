local entity = GetUpdatedEntityID()
local parent = EntityGetRootEntity(entity)

if parent == nil then return end


local x, y = EntityGetTransform(parent)
local controls_comp = EntityGetFirstComponent(parent, "ControlsComponent")
if controls_comp then x, y = ComponentGetValue2(controls_comp, "mMousePosition") end
EntitySetTransform(entity, x, y)

local spr_comp = EntityGetFirstComponentIncludingDisabled(entity, "SpriteComponent")
if not spr_comp then return end

local buffer = 15
local max_dist = 28+buffer
local min_dist = max_dist
for _,enemy in ipairs(EntityGetInRadiusWithTag(x, y, max_dist, "enemy")) do
	if EntityGetName(enemy) == "$animal_wizard_dark" then
		local ex, ey = EntityGetTransform(enemy)
		min_dist = math.min(min_dist, (((ex-x)^2 + (ey - y)^2)^.5)-buffer)
	end
end

ComponentSetValue2(spr_comp, "alpha", min_dist/max_dist)
