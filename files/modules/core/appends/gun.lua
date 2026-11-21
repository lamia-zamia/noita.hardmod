local do_global_stats = not ModSettingGet("noita.hardmod.cheeseless_triggers.disabled")

-- dont_fire_next_drawn_proj = false

DYNAMIC_TRIGGER_NONE = 0
DYNAMIC_TRIGGER_WORLD = 1
DYNAMIC_TRIGGER_TIMER = 2
DYNAMIC_TRIGGER_DEATH = 3
dynamic_trigger = DYNAMIC_TRIGGER_NONE

local null_shot_nullify = {
	"damage_electricity_add", "damage_explosion_add", "damage_explosion",
	"damage_critical_chance", "damage_ice_add", "damage_projectile_add",
	"damage_critical_chance", "damage_healing_add", "gore_particles",
}

---@param from ShotState
---@param to ShotState
local function apply_global_stats(from, to)
	if not from or from == to then return end

	if do_global_stats then
		to.fire_rate_wait = from.fire_rate_wait
		to.spread_degrees = from.spread_degrees
	end

	if from.global_null_shot and not to.global_null_shot then
		to.damage_null_all = 1
		for _,key in pairs(null_shot_nullify) do
			to[key] = 0
		end

		to.extra_entities = to.extra_entities.."data/entities/particles/tinyspark_white_small.xml,data/entities/misc/zero_damage.xml,"
		to.global_null_shot = true
	end
end

local old_draw_shot = draw_shot

---@param shot Shot
function draw_shot(shot, instant_reload_if_empty)
	apply_global_stats(c, shot.state)
	old_draw_shot(shot, instant_reload_if_empty)
	apply_global_stats(shot.state, c)
end

local _add_projectile = add_projectile
function add_projectile(...)
	if dynamic_trigger == DYNAMIC_TRIGGER_NONE then
		_add_projectile(...)

	elseif dynamic_trigger == DYNAMIC_TRIGGER_WORLD then
		dynamic_trigger = DYNAMIC_TRIGGER_NONE
		---@diagnostic disable-next-line: undefined-global
		add_projectile_trigger_hit_world(..., 1)

	elseif dynamic_trigger == DYNAMIC_TRIGGER_TIMER then
		dynamic_trigger = DYNAMIC_TRIGGER_NONE
		---@diagnostic disable-next-line: undefined-global
		add_projectile_trigger_timer(..., 20, 1)

	elseif dynamic_trigger == DYNAMIC_TRIGGER_DEATH then
		dynamic_trigger = DYNAMIC_TRIGGER_NONE
		---@diagnostic disable-next-line: undefined-global
		add_projectile_trigger_death(..., 1)
	end
end
