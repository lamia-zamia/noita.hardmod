function enabled_changed(entity_id, is_enabled)
    local wsc = EntityGetFirstComponent(GameGetWorldStateEntity(), "WorldStateComponent")
    if not wsc then EntityKill(GameGetWorldStateEntity()) return end
    if GlobalsGetValue("PLAYER_RATTINESS_LEVEL", "0") ~= "0" then return end
    ComponentSetValue2(wsc, "perk_rats_player_friendly", is_enabled)
end