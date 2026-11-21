
local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent(entity_id)
local pos_x, pos_y = EntityGetTransform(parent_id)

local comp = EntityGetFirstComponentIncludingDisabled(parent_id, "DamageModelComponent")
if not comp then return end

ComponentSetValue2(comp, "blood_material", "poison")
ComponentSetValue2(comp, "blood_spray_material", "poison")
local blood = ComponentGetValue2(comp, "blood_multiplier")
ComponentSetValue2(comp, "blood_multiplier", blood * 2)
ComponentObjectSetValue2(comp, "damage_multipliers", "poison", 0)

EntitySetDamageFromMaterial(parent_id, "poison", 0)
EntitySetDamageFromMaterial(parent_id, "poison_gas", 0)

-- local comp = EntityGetFirstComponent(root_id, "DamageModelComponent")
