local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local RADIUS = 115
local x, y = EntityGetTransform(GetUpdatedEntityID())

local nearby_shields = EntityGetInRadiusWithTag(x, y, RADIUS, "energy_shield")
if nearby_shields then
	for i,shield in ipairs(nearby_shields) do
		if EntityHasTag(EntityGetRootEntity(shield), "player_unit") then
			local shield_comp = EntityGetFirstComponentIncludingDisabled(shield, "EnergyShieldComponent")
			if shield_comp then
				local energy = ComponentGetValue2(shield_comp, "energy")
				local recharge_speed = ComponentGetValue2(shield_comp, "recharge_speed")
				ComponentSetValue2(shield_comp, "energy", math.max(energy - (recharge_speed * 2), 0))
			end
		end
	end
end
