local entity_id = GetUpdatedEntityID()
local x,y = EntityGetTransform(entity_id)

local physics_body_comp = EntityGetFirstComponent(entity_id, "PhysicsBodyComponent")
if not physics_body_comp then return end
GameCreateParticle("cursed_liquid", x, y, ComponentGetValue2(physics_body_comp, "mPixelCount")*2, 0, 0, false)