---@diagnostic disable: undefined-global
local ADD_CARD_IDS = { ADD_TRIGGER = true, ADD_TIMER = true, ADD_DEATH_TRIGGER = true }

local is_card_stepped_over = { ACTION_TYPE_MODIFIER = true, ACTION_TYPE_PASSIVE = true, ACTION_TYPE_OTHER = true, ACTION_TYPE_DRAW_MANY = true }
local is_card_trigger_source =
	{ ACTION_TYPE_PROJECTILE = true, ACTION_TYPE_STATIC_PROJECTILE = true, ACTION_TYPE_MATERIAL = true, ACTION_TYPE_UTILITY = true }

local function find_wrapped_card(card_index)
	while true do
		local card = deck[card_index]
		if not card then return nil, card_index end
		if not is_card_stepped_over[card.type] then return card, card_index end

		card_index = card_index + 1
	end
end

local function does_add_card_run(card)
	if card.type ~= ACTION_TYPE_MODIFIER then return false end
	if card.uses_remaining == 0 then return false end
	if ADD_CARD_IDS[card.id] then return false end

	return true
end

local function does_add_card_spend(card)
	if not card then return false end
	if not card.related_projectiles then return false end
	if card.uses_remaining == 0 then return false end

	return true
end

local function has_trigger_source_after(card_index)
	for index = card_index + 1, #deck do
		if is_card_trigger_source[deck[index].type] then return true end
	end

	return false
end

local function is_card_used(used_card, spends_wrapped_card)
	if not used_card then return false end
	if spends_wrapped_card then return true end

	return does_add_card_run(used_card)
end

---Pays for the spells an ADD_* spell is about to use. False when the wand cannot pay for all of them.
---@return boolean
local function pay_add_card_costs()
	if not deck or not c then return true end

	local wrapped_card, wrapped_index = find_wrapped_card(1)
	local spends_wrapped_card = does_add_card_spend(wrapped_card)
	local casts_trigger = spends_wrapped_card and has_trigger_source_after(wrapped_index)
	local mana_left = mana

	for index = 1, wrapped_index do
		if is_card_used(deck[index], spends_wrapped_card) then
			local cost = deck[index].mana or ACTION_MANA_DRAIN_DEFAULT
			if cost > mana_left then return false end

			mana_left = mana_left - cost
		end
	end

	mana = mana_left
	if casts_trigger then c.fire_rate_wait = c.fire_rate_wait + hardmod_get_card_cast_delay(wrapped_card) end

	return true
end

return {
	edit_spell = function(card)
		if ADD_CARD_IDS[card.id] then
			local run_card = card.action
			card.action = function()
				if not pay_add_card_costs() then
					OnNotEnoughManaForAction()
					return
				end

				run_card()
			end
		end
	end
}