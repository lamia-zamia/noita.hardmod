---@diagnostic disable: undefined-global

extra_modifiers.lower_spread = function()
	c.spread_degrees = c.spread_degrees - 5
	c.damage_projectile_add = c.damage_projectile_add + 0.5
	c.fire_rate_wait   = c.fire_rate_wait + 5
	shot_effects.recoil_knockback = shot_effects.recoil_knockback + 10.0
end

extra_modifiers.low_recoil = function()
	shot_effects.recoil_knockback = -128
end

local fix_modifiers = {
	"powerful_shot", "food_clock", "damage_plus_small",
	"lower_spread", "projectile_homing_shooter", "explosive_projectile",
}

for _,modifier in pairs(fix_modifiers) do
	local key = "_has_modifier_" .. modifier
	local func = extra_modifiers[modifier]

	extra_modifiers[modifier] = function()
		if c[key] then return end
		c[key] = true
		func()
	end
end
