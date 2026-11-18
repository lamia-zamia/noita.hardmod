local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

function enabled_changed( entity_id, state )
	local equipped = state
	local unequipped = not state

	local current_frame = GameGetFrameNum()
	if unequipped then
		utils.SetInternalInt( entity_id, "hardmod_unequip_frame", current_frame )
	elseif equipped then
		unequip_frame = utils.GetInternalInt( entity_id, "hardmod_unequip_frame" )
		if current_frame - unequip_frame < 3 then
			utils.SetInternalInt( entity_id, "hardmor_incur_recharge", 1 )
		end
	end

	local incur_recharge = ( utils.GetInternalInt( entity_id, "hardmor_incur_recharge" ) or 0 ) == 1
	if not incur_recharge then return end

	local owner = EntityGetRootEntity( entity_id )
	local vsc = EntityGetFirstComponentIncludingDisabled( owner, "VariableStorageComponent", "hardmod_wand_spells_cast" )
	local inv2 = EntityGetFirstComponent( owner, "Inventory2Component" )
	if not vsc then return end
	if not inv2 then return end

	local spells_cast = ( ComponentGetValue2( vsc, "value_int" ) or 0 )

	ComponentSetValue2( inv2, "mDontLogNextItemEquip", true )
	ComponentSetValue2( inv2, "mForceRefresh", true )
	ComponentSetValue2( inv2, "mActualActiveItem", 0 )

	local acomp = EntityGetFirstComponentIncludingDisabled( entity_id, "AbilityComponent" )
	if not acomp then return end

	-- local reload_time = EntityGetFirstComponentIncludingDisabled( owner, "VariableStorageComponent", "hardmod_wand_reload_time" ) or -1
	-- if reload_time == -1 then
	local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )
	local reload_time = EZWand( entity_id ).rechargeTime
	-- end

	-- only reload if the wand isn't already reloading
	local next_frame_usable = ComponentGetValue2( acomp, "mReloadNextFrameUsable" )
	if GameGetFrameNum() >= next_frame_usable then
		ComponentSetValue2( acomp, "mReloadNextFrameUsable", GameGetFrameNum() + reload_time )
		ComponentSetValue2( acomp, "mReloadFramesLeft", reload_time )
		ComponentSetValue2( acomp, "reload_time_frames", reload_time )
	end

	if reload_time > 60 then
		local x, y = EntityGetTransform( owner )
		GamePlaySound( "data/audio/Desktop/items.bank", "magic_wand/recharging", x, y )
	end

	ComponentSetValue2( vsc, "value_int", 0 )
	utils.SetInternalInt( entity_id, "hardmor_incur_recharge", 0 )
end
