dofile_once("data/scripts/lib/utilities.lua")

local entity_id    = GetUpdatedEntityID()
local x, y = EntityGetTransform( entity_id )
local vsc_comp = EntityGetFirstComponent(entity_id,"VariableStorageComponent")
local init_frame = vsc_comp and ComponentGetValue2(vsc_comp,"value_int") or 0
local warning_period = 120
local current_frame = GameGetFrameNum()

local function ShootOrb()
    if current_frame < init_frame + warning_period then return end
    SetRandomSeed( GameGetFrameNum(), x + y + entity_id )

    if ( Random( 1, 4 ) > 1 ) then
        local angle = math.rad( Random( 1, 360 ) )
        local vel_x = 0
        local vel_y = 0
        local length = Random( 40, 70 )
        
        if ( Random( 1, 4 ) > 1 ) then
            local targets = EntityGetWithTag( "player_unit" )
            local target_id = 0
            
            if ( #targets > 0 ) then
                local valid_targets = {}
                
                for i,target in ipairs(targets) do
                    local tx, ty = EntityGetTransform( target )
                    
                    local distance = math.abs( ty - y ) + math.abs( tx - x )
                    
                    if ( distance < 300 ) then
                        table.insert( valid_targets, target )
                    end
                end
                
                if ( #valid_targets > 0 ) then
                    local rnd = Random( 1, #valid_targets )
                    
                    target_id = valid_targets[rnd]
                    
                    if ( target_id ~= 0) then
                        local tx, ty = EntityGetTransform( target_id )
                        angle = 0 - math.atan2( ty - y, tx - x )
                    end
                end
            end
        end

        vel_x = math.cos( angle ) * length
        vel_y = 0- math.sin( angle ) * length
        shoot_projectile( entity_id, "mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/projectiles/orb_hearty_noclip.xml", x, y, vel_x, vel_y )
    end
end

ShootOrb()
