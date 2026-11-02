dofile_once( "data/scripts/lib/utilities.lua" )
EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )

function GenerateToolboxSpells( toolbox, amount, do_print )
	local spells = {
		-- upgrades
		"HARDMOD_UPGRADE_CAPACITY",
		"HARDMOD_UPGRADE_CAPACITY",
		"HARDMOD_UPGRADE_CAPACITY",
		"HARDMOD_UPGRADE_CAPACITY",
		"HARDMOD_UPGRADE_CAPACITY",
		"HARDMOD_UPGRADE_FIRE_RATE",
		"HARDMOD_UPGRADE_FIRE_RATE",
		"HARDMOD_UPGRADE_FIRE_RATE",
		"HARDMOD_UPGRADE_MAX_MANA",
		"HARDMOD_UPGRADE_MAX_MANA",
		"HARDMOD_UPGRADE_MAX_MANA",
		"HARDMOD_UPGRADE_MANA_CHARGE_SPEED",
		"HARDMOD_UPGRADE_MANA_CHARGE_SPEED",
		"HARDMOD_UPGRADE_MANA_CHARGE_SPEED",
		"HARDMOD_UPGRADE_REMOVE_ALWAYS_CAST",
	}

	-- try spawning the spell(s) on the toolbox
	local success = false
	toolbox = EZWand( toolbox )
	if toolbox ~= nil then
		for i=1, amount do
			if toolbox:GetFreeSlotsCount() > 0 then
				-- prevent the 'Equipped Wand' message
				local owner = EntityGetRootEntity( toolbox.entity_id )
				if owner ~= nil and EntityHasTag( owner, "player_unit" ) then
					local inv2 = EntityGetFirstComponent( owner, "Inventory2Component" )
					if inv2 ~= nil then
						if inv2 then
							ComponentSetValue2( inv2, "mDontLogNextItemEquip", true )
						end
					end
				end

				-- add a random spell from that table to the toolbox
				local spell_id = random_from_array( spells )
				toolbox:AddSpells( spell_id )
				success = true
				if do_print then
					dofile_once( "mods/D2DContentPack/files/scripts/actions.lua" )
					for i,action in ipairs( actions ) do
						if action.id == spell_id then
							local x, y = EntityGetTransform( toolbox.entity_id )
							GamePlaySound( "data/audio/Desktop/misc.bank", "game_effect/regeneration/tick", x, y )
							GamePrint( "The Toolbox generated a new spell: \"" .. GameTextGetTranslatedOrNot( action.name ) .. "\"")
							break
						end
					end
				end

			else
				if do_print then
					GamePrint( "The Toolbox is too full to generate more spells." )
				end
			end
		end
	end

	return success

	-- if the spell couldn't spawn on the toolbox, spawn it in the world instead
	-- if not spawned_in_toolbox then
	-- 	CreateItemActionEntity( random_spell, px, py )
	-- end
end

local function get_actions_lua_data( action_id )
    dofile_once( "data/scripts/gun/gun_actions.lua" )
    for i,action in ipairs( actions ) do
        if action.id == action_id then
            return action
        end
    end
    return nil
end

function UpgradeWandCapacity( wand, increase, limit )
	local old_value = wand.capacity

	if wand.capacity < limit then
		wand.capacity = math.min( old_value + increase, limit )
		GamePrint( "Your wand's capacity was increased! (" .. old_value .. " > " .. wand.capacity .. ")" )
		return true
	end

	GamePrint( "Your wand cannot hold another spell slot!" )
	return false
end

function UpgradeWandCastDelay( wand, percent, min_increase, limit )
	local old_value = wand.castDelay

	if wand.castDelay > limit then
		wand.castDelay = math.max( old_value - math.max( old_value * percent, min_increase ), limit )
		GamePrint( "Your wand's cast delay was reduced! (" .. string.format( "%.2f", old_value / 60 ) .. " > " .. string.format( "%.2f", wand.castDelay / 60 ) .. ")" )
		return true
	end

	GamePrint( "Your wand's cast delay cannot be reduced further!" )
	return false
end

function UpgradeWandRechargeTime( wand, percent, min_increase, limit )
	local old_value = wand.rechargeTime

	if wand.rechargeTime > limit then
		wand.rechargeTime = math.max( old_value - math.max( old_value * percent, min_increase ), limit )
		GamePrint("Your wand's recharge time was reduced! (" .. string.format( "%.2f", old_value / 60 ) .. " > " .. string.format( "%.2f", wand.rechargeTime / 60 ) .. ")" )
		return true
	end

	GamePrint( "Your wand's recharge time cannot be reduced further!" )
	return false
end

function UpgradeWandMaxMana( wand, percent, min_increase, limit )
	local old_value = wand.manaMax

	if wand.manaMax < limit then
		wand.manaMax = math.min( old_value + math.max( old_value * percent, min_increase ), limit )
		GamePrint( "Your wand's max mana was increased! (" .. string.format( "%.0f", old_value ) .. " > " .. string.format( "%.0f", wand.manaMax ) .. ")" )
		return true
	end

	GamePrint( "Your wand's max mana cannot be increased further!" )
	return false
end

function UpgradeWandManaChargeSpeed( wand, percent, min_increase, limit )
	local old_value = wand.manaChargeSpeed

	if wand.manaChargeSpeed < limit then
		wand.manaChargeSpeed = math.min( old_value + math.max( old_value * percent, min_increase ), limit )
		GamePrint("Your wand's mana charge speed was increased! (" .. string.format( "%.0f", old_value ) .. " > " .. string.format( "%.0f",wand.manaChargeSpeed ) .. ")" )
		return true
	end

	GamePrint( "Your wand's mana charge speed cannot be increased further!" )
	return false
end

function RemoveRandomAlwaysCast( wand )
	local spells, always_casts = wand:GetSpells()
	if #always_casts >= 1 then
		local spell_to_demote = random_from_array( always_casts )
		local spell_name = GameTextGetTranslatedOrNot( get_actions_lua_data( spell_to_demote.action_id ).name )
		GamePrint( "Your wand's always-cast '" .. spell_name .. "' was ejected!" )

		if Random( 1, 2 ) == 2 then
			local x, y = EntityGetTransform( wand.entity_id )
			CreateItemActionEntity( spell_to_demote.action_id, x, y )
		else
			GamePrint( "It was destroyed in the process..." )
		end

		EntityKill( spell_to_demote.entity_id )
		return true
	end

	GamePrint( "Your wand has no always-cast spells!" )
	return false
end
