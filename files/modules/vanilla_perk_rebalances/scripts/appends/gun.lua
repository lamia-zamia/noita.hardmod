local function try_apply_wand_experimenter_heal()
	local player = GetUpdatedEntityID()
	if not reflecting and player ~= 0 then

		-- skip if the player does not have the Wand Experimenter perk
		local pickup_count = tonumber( GlobalsGetValue( "PERK_PICKED_WAND_EXPERIMENTER_PICKUP_COUNT", "0" ) )
		if pickup_count == 0 then return end

		-- skip if the player is wounded
		local is_wounded = GameGetGameEffect( player, "NO_HEAL" ) or 0
		if is_wounded ~= 0 then return end

		-- get the player's active item, and verify that it's a wand
		local inv2_comp = EntityGetFirstComponentIncludingDisabled( player, "Inventory2Component" )
		if inv2_comp == nil then return end
		local active_item = ComponentGetValue2( inv2_comp, "mActiveItem" )
		local acomp = EntityGetFirstComponentIncludingDisabled( active_item, "AbilityComponent" )
		if not acomp or ComponentGetValue2( acomp, "use_gun_script" ) == false then return end

		-- skip if the wand had been tinkered with
		wand_entity = active_item
		local edit_count = tonumber( ComponentGetValue2( acomp, "stat_times_player_has_edited") )
		if edit_count > 0 then return end

		-- skip if any spells had been dropped to the ground
		local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
		if #discarded ~= utils.GetInternalInt( wand_entity, "initial_spell_count" ) then return end

		-- skip if the player already has full hp
		local dmg_comp = EntityGetFirstComponentIncludingDisabled( player, "DamageModelComponent" )
		if not dmg_comp then return end
		local p_hp = ComponentGetValue2( dmg_comp, "hp" )
		local p_max_hp = ComponentGetValue2( dmg_comp, "max_hp" )
		if p_hp == p_max_hp then return end

		-- finally, apply the heals
		local wand_tier = utils.GetInternalInt( wand_entity, "wand_tier" )
		local heal = 0
		local x,y = EntityGetTransform( player )
		if #deck == 0 then
			-- skip if there are no big heals remaining for this wand
			local big_heals_applied = utils.GetInternalInt( wand_entity, "hardmod_wandex_big_heals_applied" ) or 0
			local max_big_heals = 1
			if big_heals_applied >= max_big_heals then return end

			heal = wand_tier * 0.4 -- i.e. tier 1 = 10 hp, tier 2 = 20 hp, ...
			ComponentSetValue2( dmg_comp, "hp", math.min( p_hp + heal, p_max_hp ) )

			-- increase the heal counter, play a sound + visual effect
			utils.SetInternalInt( wand_entity, "hardmod_wandex_big_heals_applied", big_heals_applied + 1 )
			EntityLoad( "data/entities/particles/heal_effect.xml", x, y )
			local heal_applied = true
		-- else
		-- 	-- skip if there are no small heals remaining for this wand
		-- 	local small_heals_applied = utils.GetInternalInt( wand_entity, "hardmod_wandex_small_heals_applied" ) or 0
		-- 	local max_small_heals = 5
		-- 	if small_heals_applied >= max_small_heals then return end

		-- 	heal = wand_tier * 0.04 -- i.e. tier 1 = 5x1 hp, tier 2 = 5x2 hp, ...
		-- 	ComponentSetValue2( dmg_comp, "hp", math.min( p_hp + heal, p_max_hp ) )

		-- 	-- increase the heal counter, play only a sound effect
		-- 	utils.SetInternalInt( wand_entity, "hardmod_wandex_small_heals_applied", small_heals_applied + 1 )
		-- 	GamePlaySound( "data/audio/Desktop/misc.bank", "game_effect/regeneration/tick", x, y )
		end
	end
end

local _move_hand_to_discarded = move_hand_to_discarded
function move_hand_to_discarded()
	_move_hand_to_discarded()
	try_apply_wand_experimenter_heal()
end
