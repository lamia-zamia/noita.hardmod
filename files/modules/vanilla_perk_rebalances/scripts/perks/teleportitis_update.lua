
local entity_id = GetUpdatedEntityID()
local owner = EntityGetRootEntity( entity_id )
local x, y = EntityGetTransform( owner )

local platcomp = EntityGetFirstComponentIncludingDisabled( owner, "CharacterPlatformingComponent" )
if not platcomp then return end
local frames_in_air = ComponentGetValue2( platcomp, "mFramesInAirCounter" )

local controls = EntityGetFirstComponent( owner, "ControlsComponent" )
local is_fly_pressed = ComponentGetValue2( controls, "mButtonDownFly" )

local markers = EntityGetWithTag( "hardmod_rewind_marker" )
if markers ~= nil and frames_in_air == 0 then
    for i,marker_id in ipairs( markers ) do
        EntityKill( marker_id )
    end
elseif is_fly_pressed and frames_in_air == 1 then
    local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" )
    local last_hit_frame = utils.GetInternalInt( owner, "hardmod_teleportitis_last_tele_frame" ) or 0
    if GameGetFrameNum() - last_hit_frame > 300 then
        -- player jumped
        GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/teleport/create", x, y )
        EntityLoad( "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/perks/rewind_marker.xml", x, y )
    end
end
