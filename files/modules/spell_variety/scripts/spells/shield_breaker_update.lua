local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local x, y = EntityGetTransform(GetUpdatedEntityID())

local nearby_shields = EntityGetWithTag("energy_shield")
if nearby_shields then
	for i,shield in ipairs(nearby_shields) do
		if not EntityHasTag(EntityGetRootEntity(shield), "player_unit") then
			local shield_comp = EntityGetFirstComponentIncludingDisabled(shield, "EnergyShieldComponent")
			if shield_comp then
				local sx, sy = EntityGetTransform(shield)
				local radius = ComponentGetValue2(shield_comp, "radius")
				if utils.get_distance(x, y, sx, sy) < radius + 32 then
					local energy = ComponentGetValue2(shield_comp, "energy")
					local recharge_speed = ComponentGetValue2(shield_comp, "recharge_speed")
					ComponentSetValue2(shield_comp, "energy", 0)
				end
			end
		end
	end
end
