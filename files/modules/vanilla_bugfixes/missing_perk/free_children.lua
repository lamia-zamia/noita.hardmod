local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)

-- Check if both chunks are loaded every 2f, and de-child the perks if yes.
if DoesWorldExistAt(x, y, x+60, y) then --60 is the magic range of the X position where perks on the altar can spawn.
    for _, c in ipairs(EntityGetAllChildren(entity_id) or {}) do
        EntityRemoveFromParent(c) --Perks cannot be picked up if they have a parent.
    end
    EntityKill(entity_id)
end
