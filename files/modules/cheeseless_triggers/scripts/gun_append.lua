
local _draw_action = draw_action
function draw_action( instant_reload_if_empty )
	local action = nil

	state_cards_drawn = state_cards_drawn + 1

	if reflecting then  return  end


	if ( #deck <= 0 ) then
		if instant_reload_if_empty and ( force_stop_draws == false ) then
			move_discarded_to_deck()
			order_deck()
			start_reload = true
		else
			reloading = true
			return true -- <------------------------------------------ RETURNS
		end
	end

	if #deck > 0 then
		-- draw from the start of the deck
		action = deck[ 1 ]

		table.remove( deck, 1 )
		
		-- update mana
		local action_mana_required = action.mana
		if action.mana == nil then
			action_mana_required = ACTION_MANA_DRAIN_DEFAULT
		end

		if action_mana_required > mana then
			OnNotEnoughManaForAction()
			table.insert( discarded, action )
			return false -- <------------------------------------------ RETURNS
		end

		if action.uses_remaining == 0 then
			table.insert( discarded, action )
			return false -- <------------------------------------------ RETURNS
		end

		mana = mana - action_mana_required
	end

	--- add the action to hand and execute it ---
	if action ~= nil then
		play_action( action )
	end

	return true
end
