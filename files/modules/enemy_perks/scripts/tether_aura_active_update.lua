local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local RADIUS = 220
local MAX_OWNER_FOLLOW_SPEED = 1

local aura = GetUpdatedEntityID()
local owner = EntityGetRootEntity(aura)
local x, y = EntityGetTransform(aura)

local function ease_angle(angle, target_angle, easing)
    local dir = (angle - target_angle) / (math.pi * 2)
    dir = dir - math.floor(dir + 0.5)
    dir = dir * (math.pi * 2)
    return angle - dir * easing
end

local function follow_owner()
    local ox, oy = EntityGetTransform(owner)
    local dx = ox - x
    local dy = oy - y
    local dist = math.sqrt(dx * dx + dy * dy)

    if dist > MAX_OWNER_FOLLOW_SPEED then
	    local dir_x = dx / dist
	    local dir_y = dy / dist
	    EntitySetTransform(aura,
	    	x + (dir_x * MAX_OWNER_FOLLOW_SPEED),
	    	y + (dir_y * MAX_OWNER_FOLLOW_SPEED))
	elseif dist > RADIUS then
		EntityKill(aura)
		EntityAddChild(owner, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/tether_aura_dormant.xml", x, y))
	else
		EntitySetTransform(aura, ox, oy)
	end
end

local function check_for_player()
	local nearest_player = EntityGetInRadiusWithTag(x, y, RADIUS, "player_unit")[1]
	if not nearest_player then
		local players = EntityGetWithTag("player_unit")
		if players then
			for _,player in ipairs(players) do
				local dmg_comp = EntityGetFirstComponentIncludingDisabled(player, "DamageModelComponent")
				if dmg_comp ~= nil then
					local p_hp = ComponentGetValue2(dmg_comp, "hp")
					local p_max_hp = ComponentGetValue2(dmg_comp, "max_hp")

					EntityInflictDamage(player, math.min(p_max_hp * 0.2, p_hp * 0.5), "DAMAGE_SLICE", "broken tether", "NORMAL", 0, 0)
				end
			end
		end
		EntityKill(aura)
		EntityAddChild(owner, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/tether_aura_dormant.xml", x, y))
	end
end

follow_owner()
check_for_player()
