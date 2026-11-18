
local x, y = EntityGetTransform(GetUpdatedEntityID())

local nearby_mortals = EntityGetInRadiusWithTag(x, y, 32, "mortal")
if nearby_mortals then
	for i,mortal in ipairs(nearby_mortals) do
		local is_wounded = GameGetGameEffect(mortal, "NO_HEAL") or 0
		if is_wounded == 0 then
			local dmg_comp = EntityGetFirstComponentIncludingDisabled(mortal, "DamageModelComponent")
			if dmg_comp ~= nil then
				local p_hp = ComponentGetValue2(dmg_comp, "hp")
				local p_max_hp = ComponentGetValue2(dmg_comp, "max_hp")

				local heal = math.max(0.12, p_max_hp * 0.01)
				ComponentSetValue2(dmg_comp, "hp", math.min(p_hp + heal, p_max_hp))
				-- heal 3 hp or 1% of max hp (whichever is higher) per tick

				GamePlaySound("data/audio/Desktop/misc.bank", "game_effect/regeneration/tick", x, y)
			end
		end
	end
end
