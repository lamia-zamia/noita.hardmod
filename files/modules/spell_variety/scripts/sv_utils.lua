local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

local sv_utils = {}

local function split_string(inputstr, sep)
  sep = sep or "%s"
  local t= {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

function sv_utils.MultiplyMoveSpeed( entity_id, effect_name, mtp_x, mtp_y )
	if not mtp_y then mtp_y = 1.0 + ( 0.5 * ( mtp_x - 1.0 ) ) end

	if utils.GetInternalString( entity_id, effect_name .. "_move_speed_mtp" ) == nil then
	    local plat_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterPlatformingComponent" )

	    ComponentSetValue2( plat_comp, "velocity_min_x", ComponentGetValue2( plat_comp, "velocity_min_x" ) * mtp_x )
	    ComponentSetValue2( plat_comp, "velocity_max_x", ComponentGetValue2( plat_comp, "velocity_max_x" ) * mtp_x )
	    ComponentSetValue2( plat_comp, "jump_velocity_y", ComponentGetValue2( plat_comp, "jump_velocity_y" ) * mtp_y )
	    ComponentSetValue2( plat_comp, "jump_velocity_x", ComponentGetValue2( plat_comp, "jump_velocity_x" ) * mtp_x )
	    ComponentSetValue2( plat_comp, "fly_speed_max_up", ComponentGetValue2( plat_comp, "fly_speed_max_up" ) * mtp_y )
	    ComponentSetValue2( plat_comp, "fly_speed_max_down", ComponentGetValue2( plat_comp, "fly_speed_max_down" ) * mtp_y )
	    ComponentSetValue2( plat_comp, "fly_velocity_x", ComponentGetValue2( plat_comp, "fly_velocity_x" ) * mtp_x )

		utils.SetInternalString( entity_id, effect_name .. "_move_speed_mtp", mtp_x .. "," .. mtp_y )
	end
end

function sv_utils.ResetMoveSpeed( entity_id, effect_name )
	-- don't execute this function if the same effect already exists
	-- if utils.GetInternalString( entity_id, effect_name .. "_move_speed_mtp" ) ~= nil then return end

    local plat_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterPlatformingComponent" )

    stored_mtp_value = utils.GetInternalString( entity_id, effect_name .. "_move_speed_mtp" )
    local parsed = split_string( stored_mtp_value, ',' )
    local mtp_x = 1.0 / parsed[1]
    local mtp_y = 1.0 / parsed[2]

    local plat_comp = EntityGetFirstComponentIncludingDisabled( entity_id, "CharacterPlatformingComponent" )
    ComponentSetValue2( plat_comp, "velocity_min_x", ComponentGetValue2( plat_comp, "velocity_min_x" ) * mtp_x )
    ComponentSetValue2( plat_comp, "velocity_max_x", ComponentGetValue2( plat_comp, "velocity_max_x" ) * mtp_x )
    ComponentSetValue2( plat_comp, "jump_velocity_y", ComponentGetValue2( plat_comp, "jump_velocity_y" ) * mtp_y )
    ComponentSetValue2( plat_comp, "jump_velocity_x", ComponentGetValue2( plat_comp, "jump_velocity_x" ) * mtp_x )
    ComponentSetValue2( plat_comp, "fly_speed_max_up", ComponentGetValue2( plat_comp, "fly_speed_max_up" ) * mtp_y )
    ComponentSetValue2( plat_comp, "fly_speed_max_down", ComponentGetValue2( plat_comp, "fly_speed_max_down" ) * mtp_y )
    ComponentSetValue2( plat_comp, "fly_velocity_x", ComponentGetValue2( plat_comp, "fly_velocity_x" ) * mtp_x )

    local vsc = get_variable_storage_component( entity_id, effect_name .. "_move_speed_mtp" )
    EntityRemoveComponent( entity_id, vsc )
end

return sv_utils
