extra_modifiers.projectile_homing = function()
	c.extra_entities = c.extra_entities .. "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/homing_perk.xml,"
end

extra_modifiers.lower_spread = function()
	c.spread_degrees = c.spread_degrees - 5
	c.damage_projectile_add = c.damage_projectile_add + 1
	c.fire_rate_wait   = c.fire_rate_wait + 1
	shot_effects.recoil_knockback = shot_effects.recoil_knockback + 10.0
end

extra_modifiers.low_recoil = function()
	shot_effects.recoil_knockback = -128
end

-- TODO: Make this work with multiple pinpointer spells
-- 		 Make this NOT give extra reductions for every separate shotstate in a cast
extra_modifiers.laser_aim = function()
	local new = c.spread_degrees - 10
	-- print("laser_aim", c.spread_degrees, new)
	c.spread_degrees = new
	c.speed_multiplier = c.speed_multiplier * 1.4
end

local fix_modifiers = {
	"critical_hit_boost", "critical_plus_small", "powerful_shot", "food_clock", "damage_plus_small",
	"damage_projectile_boost", "lower_spread", "projectile_homing_shooter", "explosive_projectile",
	"laser_aim",
}

for _,modifier in pairs(fix_modifiers) do
	local key = "hardmod_has_modifier_" .. modifier
	local func = extra_modifiers[modifier]

	extra_modifiers[modifier] = function()
		if c[key] then return end
		c[key] = true
		func()
	end
end
