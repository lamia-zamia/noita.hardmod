local hooks = {}

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

hooks.edit_spell = function(card)
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

hooks.new_spells = {
	{
		id = "HARDMOD_SACRILEGE",
		name = "$hardmod_spell_sacrilege_name",
		description = "$hardmod_spell_sacrilege_desc",
		sprite = "mods/noita.hardmod/files/modules/cheeseless_triggers/gfx/ui_gfx/spells/sacrilege.png",
		type = ACTION_TYPE_OTHER,
		spawn_level = "5,6,10",
		spawn_probability = "0.6,0.6,1",
		spawn_requires_flag = "card_unlocked_mestari",
		price = 400,
		mana = 80,
		action = function()
			-- original Add Trigger function (i.e. copies modifiers for free), except it doesn't add a trigger
			local data = {}
			
			local how_many = 1
			
			if ( #deck > 0 ) then
				data = deck[1]
			else
				data = nil
			end
			
			if ( data ~= nil ) then
				while ( #deck >= how_many ) and ( ( data.type == ACTION_TYPE_MODIFIER ) or ( data.type == ACTION_TYPE_PASSIVE ) or ( data.type == ACTION_TYPE_OTHER ) or ( data.type == ACTION_TYPE_DRAW_MANY ) ) do
					if ( ( data.uses_remaining == nil ) or ( data.uses_remaining ~= 0 ) ) and ( data.id ~= "ADD_TRIGGER" ) and ( data.id ~= "ADD_TIMER" ) and ( data.id ~= "ADD_DEATH_TRIGGER" ) and ( data.id ~= "HARDMOD_SACRILEGE" ) then
						if ( data.type == ACTION_TYPE_MODIFIER ) then
							dont_draw_actions = true
							data.action()
							dont_draw_actions = false
						end
					end
					how_many = how_many + 1
					data = deck[how_many]
				end
				
				if ( data ~= nil ) and ( data.related_projectiles ~= nil ) and ( ( data.uses_remaining == nil ) or ( data.uses_remaining ~= 0 ) ) then
					local target = data.related_projectiles[1]
					local count = data.related_projectiles[2] or 1
					
					for i=1,how_many do
						data = deck[1]
						table.insert( discarded, data )
						table.remove( deck, 1 )
					end
					
					local valid = false
					
					for i=1,#deck do
						local check = deck[i]
						
						if ( check ~= nil ) and ( ( check.type == ACTION_TYPE_PROJECTILE ) or ( check.type == ACTION_TYPE_STATIC_PROJECTILE ) or ( check.type == ACTION_TYPE_MATERIAL ) or ( check.type == ACTION_TYPE_UTILITY ) ) then
							valid = true
							break
						end
					end
					
					if ( data.uses_remaining ~= nil ) and ( data.uses_remaining > 0 ) then
						data.uses_remaining = data.uses_remaining - 1
						
						local reduce_uses = ActionUsesRemainingChanged( data.inventoryitem_id, data.uses_remaining )
						if not reduce_uses then
							data.uses_remaining = data.uses_remaining + 1 -- cancel the reduction
						end
					end
					
					if valid then
						for i=1,count do
							add_projectile(target)
						end
					else
						dont_draw_actions = true
						data.action()
						dont_draw_actions = false
					end
				end
			end
		end,
	},
}

hooks.spell_patches = {
	["ADD_TRIGGER"] = {
		type = ACTION_TYPE_MODIFIER,
		description = "$hardmod_spell_add_trigger_desc",
		-- spawn_level = "1,2,3,4,5,6" -- very rare early spawns because they are just fun spells
		-- spawn_probability = "0.05,0.1,0.2,0.3,0.4,0.4"
		spawn_probability = 0,
		spawn_requires_flag = nil,
		mana = 20,
		action = function()
			if reflecting then return end
			dynamic_trigger = DYNAMIC_TRIGGER_WORLD
			draw_actions( 1, true )
			dynamic_trigger = DYNAMIC_TRIGGER_NONE
		end,
	},
	["ADD_TIMER"] = {
		type = ACTION_TYPE_MODIFIER,
		description = "$hardmod_spell_add_timer_desc",
		-- spawn_level = "1,2,3,4,5,6" -- very rare early spawns because they are just fun spells
		-- spawn_probability = "0.05,0.1,0.2,0.3,0.4,0.4"
		spawn_probability = 0,
		spawn_requires_flag = nil,
		action = function()
			if reflecting then return end
			dynamic_trigger = DYNAMIC_TRIGGER_TIMER
			draw_actions( 1, true )
			dynamic_trigger = DYNAMIC_TRIGGER_NONE
		end,
	},
	["ADD_DEATH_TRIGGER"] = {
		type = ACTION_TYPE_MODIFIER,
		description = "$hardmod_spell_add_death_trigger_desc",
		-- spawn_level = "1,2,3,4,5,6" -- very rare early spawns because they are just fun spells
		-- spawn_probability = "0.05,0.1,0.2,0.3,0.4,0.4"
		spawn_probability = 0,
		spawn_requires_flag = nil,
		action = function()
			if reflecting then return end
			dynamic_trigger = DYNAMIC_TRIGGER_DEATH
			draw_actions( 1, true )
			dynamic_trigger = DYNAMIC_TRIGGER_NONE
		end,
	},
}

return hooks
