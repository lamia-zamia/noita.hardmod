if not actions then dofile_once("data/scripts/gun/gun_actions.lua") end

local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" )---@type utils
local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )

local function get_max_uses( card_action )
	local itemx_comp = EntityGetFirstComponentIncludingDisabled( card_action, "ItemActionComponent" )
	if itemx_comp then
		local spell_id = ComponentGetValue2( itemx_comp, "action_id" )
		for i,action in ipairs( actions ) do
			if action.id == spell_id then
				return action.max_uses
			end
		end
	end
end

local function is_never_unlimited( card_action )
	local itemx_comp = EntityGetFirstComponentIncludingDisabled( card_action, "ItemActionComponent" )
	if itemx_comp then
		local spell_id = ComponentGetValue2( itemx_comp, "action_id" )
		for i,action in ipairs( actions ) do
			if action.id == spell_id then
				return action.never_unlimited
			end
		end
	end
end

local function trigger_wand_refresh( wand, mtp, min_reload_time )
	if not wand then return end
	local player = EntityGetRootEntity( wand.entity_id )

	local inv2_comp = EntityGetFirstComponent( player, "Inventory2Component" )
	if inv2_comp ~= nil then
		if inv2_comp then
			-- This will only skip 1 equip message, but it's better than nothing
			ComponentSetValue2( inv2_comp, "mDontLogNextItemEquip", true )
		end

		ComponentSetValue2( inv2_comp, "mForceRefresh", true )
		ComponentSetValue2( inv2_comp, "mActualActiveItem", 0 )

		local acomp = EntityGetFirstComponentIncludingDisabled( wand.entity_id, "AbilityComponent" )
		local reload_time = math.max( wand.rechargeTime, min_reload_time or 0 ) * mtp

		-- only reload if the wand isn't already reloading
		local next_frame_usable = ComponentGetValue2( acomp, "mReloadNextFrameUsable" )
		if GameGetFrameNum() >= next_frame_usable then
			ComponentSetValue2( acomp, "mReloadNextFrameUsable", GameGetFrameNum() + reload_time )
			ComponentSetValue2( acomp, "mReloadFramesLeft", reload_time )
			ComponentSetValue2( acomp, "reload_time_frames", reload_time )
		end
	end
end

function item_pickup( entity_item, entity_who_picked, item_name )
	local children = EntityGetAllChildren( entity_who_picked )
	for k=1,#children do
		child = children[k]

		local all_card_actions = {}

		-- insert all spells slotted in wands
	    if EntityGetName( child ) == "inventory_quick" then
	        local inventory_items = EntityGetAllChildren( child )
	        if( inventory_items ~= nil ) then
	            for z=1, #inventory_items do
	            	item = inventory_items[z]
	            	if item > 0 then
	            		if EZWand.IsWand( item ) then
		            		local wand = EZWand( item )
		            		local spells,attached_spells = wand:GetSpells()
		            		for i,spell in ipairs( spells ) do
		            			table.insert( all_card_actions, spell.entity_id )
		            		end
		            	else
		            		-- also restore charges to materialized bombs
		            		local item_comp = EntityGetFirstComponentIncludingDisabled( item, "ItemComponent" )
		            		if item_comp ~= nil then
		            			local uses_remaining = ComponentGetValue2( item_comp, "uses_remaining" )
		            			if uses_remaining ~= nil and uses_remaining > -1 then
		            				table.insert( all_card_actions, item )
		            			end
		            		end
		            	end
	            	end
	            end
	        end
	    end

	    -- insert all spells in the 'full' inventory
	    if EntityGetName( child ) == "inventory_full" then
	        local inv_card_actions = EntityGetAllChildren( child )
	        if( inv_card_actions ~= nil ) then
	            for z=1, #inv_card_actions do
	            	inv_card_action = inv_card_actions[z]

	            	local item_comp = EntityGetFirstComponentIncludingDisabled( inv_card_action, "ItemComponent" )
	            	if item_comp then
	    				table.insert( all_card_actions, inv_card_action )
	            	end
	            end
	        end
	    end

	    for i,card_action in ipairs( all_card_actions ) do
	    	local charge_amount = 0

		    local item_comp = EntityGetFirstComponentIncludingDisabled( card_action, "ItemComponent" )
			local max_uses = get_max_uses( card_action )
			if item_comp and max_uses and max_uses > -1 then

				local uses_remaining = ComponentGetValue2( item_comp, "uses_remaining" )
				if uses_remaining < max_uses then

					local do_restore = true
					-- if the spell is "never unlimited", give it a 75% chance to be skipped
					if is_never_unlimited( card_action ) then
						do_restore = Random( 1, 100 ) < 25
					end

					if do_restore then
						charge_amount = charge_amount + math.ceil( max_uses / 10 )

						if Random( 1, 10 ) < max_uses % 10 then
							charge_amount = charge_amount + 1
						end
					end
				end

				if charge_amount > 0 then
					local itemx_comp = EntityGetFirstComponentIncludingDisabled( card_action, "ItemActionComponent" )
					if itemx_comp then
						local new_uses = math.min( uses_remaining + charge_amount, max_uses )
						ComponentSetValue2( item_comp, "uses_remaining", new_uses )

						local spell_id = ComponentGetValue2( itemx_comp, "action_id" )
						for i,action in ipairs( actions ) do
							if action.id == spell_id then
								local diff = ( new_uses - uses_remaining )

								local msg = "+" .. diff .. " " .. GameTextGetTranslatedOrNot( action.name )
								-- if diff > 1 then msg = msg .. "s" end
								GamePrint( msg )
							end
						end
					end
				end
			end
	    end
	end

    -- play a little sound, show a little vfx
    local x, y = EntityGetTransform( entity_item )
	GamePlaySound( "data/audio/Desktop/event_cues.bank", "event_cues/pick_item_generic/create", x, y )
	EntityLoad( "data/entities/particles/gold_pickup_large.xml", x, y )

	-- reload current wand to accurately show new remaining uses
	local held_wand = EZWand.GetHeldWand()
	if held_wand ~= nil then
		trigger_wand_refresh( held_wand, 1.0 )
	end

    -- destroy the gem
	EntityKill( entity_item )
end
