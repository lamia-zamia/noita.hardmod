dofile_once( "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/scripts/perks/toolbox_utils.lua" )

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )
local currbiome = BiomeMapGetName( x, y )
local flag = "toolbox_" .. tostring(currbiome) .. "_visited"

local prev_hm_count = tonumber( GlobalsGetValue( "HARDMOD_TOOLBOX_PREV_HM_COUNT", "0" ) )
local curr_hm_count = tonumber( GlobalsGetValue( "HOLY_MOUNTAIN_VISITS", "0" ) )

local is_new_hm = curr_hm_count > prev_hm_count
if is_new_hm then
	GlobalsSetValue( "HARDMOD_TOOLBOX_PREV_HM_COUNT", tostring( curr_hm_count ) )
end

if not GameHasFlagRun( flag ) or ( is_new_hm and curr_hm_count > 1 ) then
	if GenerateToolboxSpells( entity_id, 1, true ) then
		GameAddFlagRun( flag )
	end
end
