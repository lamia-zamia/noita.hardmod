local label_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(label_id)

EntitySetTransform(label_id, x, y - 0.25)

local sprite_comp = EntityGetFirstComponentIncludingDisabled(label_id, "SpriteComponent")
if sprite_comp ~= nil then
	local alpha = ComponentGetValue2(sprite_comp, "alpha")
	ComponentSetValue2(sprite_comp, "alpha", alpha - 0.0167)
end
