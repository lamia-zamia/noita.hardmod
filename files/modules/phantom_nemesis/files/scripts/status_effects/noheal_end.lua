
local entity_id = GetUpdatedEntityID()
local target = EntityGetRootEntity(entity_id)
local x, y = EntityGetTransform(entity_id)

local c = EntityLoad("mods/noita.hardmod/files/modules/phantom_nemesis/entities/status_effects/effect_nohealing_remove.xml", x, y)
EntityAddChild(target, c)
