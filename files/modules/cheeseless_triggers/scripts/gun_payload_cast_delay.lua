payload_cast_delay_scale = 1.0 -- Fraction of the payload's cast delay
payload_spread_degrees_scale = 1.0

local card_cast_delays = {}
local card_spawn_helpers =
	{ "add_projectile", "add_projectile_trigger_timer", "add_projectile_trigger_hit_world", "add_projectile_trigger_death", "baab_instruction" }

--- Fake real-time reflection
local function measure_card_cast_delay(card)
	local saved_c = c
	local saved_dont_draw_actions = dont_draw_actions
	local saved_reflecting = reflecting
	local saved_helpers = {}
	for _, name in ipairs(card_spawn_helpers) do
		saved_helpers[name] = _G[name]
		_G[name] = function() end
	end
	dont_draw_actions = true
	reflecting = true

	local played, delay = pcall(function()
		c = create_shot(1).state
		card.action()
		return c.fire_rate_wait
	end)

	c = saved_c
	dont_draw_actions = saved_dont_draw_actions
	reflecting = saved_reflecting
	for _, name in ipairs(card_spawn_helpers) do
		_G[name] = saved_helpers[name]
	end

	return played and delay or 0
end

--- Gets cast delay, measured once per spell
function hardmod_get_card_cast_delay(card)
	if not card or not card.id then return 0 end

	local known_delay = card_cast_delays[card.id]
	if known_delay == nil then
		known_delay = measure_card_cast_delay(card)
		card_cast_delays[card.id] = known_delay
	end

	return known_delay
end
