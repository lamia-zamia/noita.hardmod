local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

function enabled_changed(entity_id, is_enabled)
    if not is_enabled then return end
    local itx_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "InheritTransformComponent")
    if not itx_comp then return end
    local wand_entity = EntityGetParent(entity_id)
    if not wand_entity or not EntityHasTag(wand_entity, "wand") then return end
    local hs_comp = EntityGetFirstComponentIncludingDisabled(wand_entity, "HotspotComponent")
    if not hs_comp then return end
    local spr_comp = EntityGetFirstComponentIncludingDisabled(wand_entity, "SpriteComponent")
    if not spr_comp then return end

    local hs_x, _ = ComponentGetValue2(hs_comp, "offset")
    local spr_x = ComponentGetValue2(spr_comp, "offset_x")
    ComponentSetValue2(itx_comp, "Transform", hs_x + spr_x - 1, 0, 0, 0, 0) -- -1 makes it align just a bit more nicely
end
