local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local entity_id = GetUpdatedEntityID()

local function has_vsc( entity_id, variable_name )
	local vs_comps = EntityGetComponent( entity_id, "VariableStorageComponent" )	
	if vs_comps ~= nil then
		for _,vs_comp in pairs( vs_comps ) do 
			local var_name = ComponentGetValue2( vs_comp, "name" )
			if( var_name == variable_name ) then
				return true
			end
		end
	end
	return false
end
if has_vsc( entity_id, "no_gold_drop" ) then return end

-- scale from 20% chance to drop at 0 HP, to 50% chance at 500 HP
local dmg_comp = EntityGetFirstComponent( entity_id, "DamageModelComponent" )
if dmg_comp then
	local max_hp = ComponentGetValue2( dmg_comp, "max_hp" )
	local chance_to_drop = utils.Remap( max_hp, 0, 20, 20, 50 )
	local rnd = Random( 1, 100 )
	local gems_dropped = 0
	while rnd < chance_to_drop and gems_dropped < 10 do
		local x, y = EntityGetTransform( entity_id )
		local offset_x = Random( -4, 4 )
		local offset_y = Random( -4, 4 )
		EntityLoad( "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/items/spell_gem.xml", x + offset_x, y + offset_y )

		-- reset rnd
		SetRandomSeed( -entity_id + gems_dropped, entity_id - gems_dropped )
		rnd = Random( 1, 100 )
		gems_dropped = gems_dropped + 1
	end
end
