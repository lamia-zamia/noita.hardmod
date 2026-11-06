local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils
local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )
local sv_utils = dofile_once( "mods/noita.hardmod/files/modules/spell_variety/scripts/sv_utils.lua" ) ---@type sv_utils

-- entity id and internal vars
local player = EntityGetRootEntity( GetUpdatedEntityID() )
local x, y = EntityGetTransform( player )
local wand_id = EntityGetParent( GetUpdatedEntityID() )
if not EZWand.IsWand( wand_id ) then return end
local wand = EZWand( wand_id )
if not wand then return end

local ability_comp = EntityGetFirstComponentIncludingDisabled( wand.entity_id, "AbilityComponent" )
if ability_comp then
	local reload_ready_frame = ComponentGetValue2( ability_comp, "mReloadNextFrameUsable" )

	-- if the wand is done recharging...
	if reload_ready_frame < GameGetFrameNum() + 15 then

		-- ...disable the shield...
		local shield_comps = EntityGetComponent( GetUpdatedEntityID(), "EnergyShieldComponent" )
		if shield_comps then
			for i,shield_comp in ipairs( shield_comps ) do
				ComponentSetValue2( shield_comp, "energy", 0 )
			end
		end

		-- ...and remove the move speed boost
		if ( utils.GetInternalInt( GetUpdatedEntityID(), "hardmod_recharge_rush_mov_speed_applied" ) or 0 ) == 1 then
			sv_utils.ResetMoveSpeed( player, "hardmod_recharge_rush" )
			utils.SetInternalInt( GetUpdatedEntityID(), "hardmod_recharge_rush_mov_speed_applied", 0 )
		end

		EntitySetComponentsWithTagEnabled( player, "hardmod_recharge_shield_active", false )
	else
		-- if the wand starts recharging...
		-- ...apply the move speed boost...
		wand.mana = math.min( wand.mana + ( ( wand.manaChargeSpeed / 60 ) * 3.0 ), wand.manaMax )
		if ( utils.GetInternalInt( GetUpdatedEntityID(), "hardmod_recharge_rush_mov_speed_applied" ) or 0 ) == 0 then
			sv_utils.MultiplyMoveSpeed( player, "hardmod_recharge_rush", 2.0, 1.5 )
			utils.SetInternalInt( GetUpdatedEntityID(), "hardmod_recharge_rush_mov_speed_applied", 1 )
		    GamePlaySound( "data/audio/Desktop/misc.bank", "misc/telekinesis/grab_complete", x, y )
		end

		-- ...and refill the shield
		local shield_comps = EntityGetComponent( GetUpdatedEntityID(), "EnergyShieldComponent" )
		for i,shield_comp in ipairs( shield_comps ) do
			ComponentSetValue2( shield_comp, "energy", ComponentGetValue2( shield_comp, "max_energy" ) )
		end

		EntitySetComponentsWithTagEnabled( player, "hardmod_recharge_shield_active", true )
	end
end
