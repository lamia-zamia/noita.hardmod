-- local affect_effects = {
-- 	["PROJECTILE_HOMING"] = true,
-- }

function enabled_changed(entity_id, is_enabled)
	local player = entity_id
	while player and player ~= 0 and not EntityHasTag(player, "player_unit") do
		player = EntityGetParent(player)
	end

	if not player or player == 0 then
		print("Inhibitor spell: No player found on", is_enabled and "enable" or "disable")
		return
	end

	local perk_shot_effects = EntityGetComponentIncludingDisabled(player, "ShotEffectComponent", "perk_component")
	for _,effect in pairs(perk_shot_effects or {}) do
		EntitySetComponentIsEnabled(player, effect, not is_enabled)
	end

	-- I LOVE NOLLA, THANK YOU FOR MAKING GAMEEFFECTCOMPONENT NOT RESPECT DISABLED

	-- local perk_entities = EntityGetAllChildren(player, "perk_entity")
	-- for _,perk in pairs(perk_entities or {}) do
	-- 	local effects = EntityGetComponentIncludingDisabled(perk, "GameEffectComponent")
	-- 	for _,effect in pairs(effects or {}) do
	-- 		if affect_effects[ComponentGetValue2(effect, "effect")] then
	-- 			EntitySetComponentIsEnabled(perk, effect, not is_enabled)
	-- 		end
	-- 	end
	-- end
end
