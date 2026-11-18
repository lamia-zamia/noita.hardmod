
local entity_id = GetUpdatedEntityID()

EntitySetDamageFromMaterial(entity_id, "lava", 0.0)
EntitySetDamageFromMaterial(entity_id, "acid", 0.0004) --90% less damage than usual
EntitySetDamageFromMaterial(entity_id, "blood_cold", 0)
EntitySetDamageFromMaterial(entity_id, "blood_cold_vapour", 0)
