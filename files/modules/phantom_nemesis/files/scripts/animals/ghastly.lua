
local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent(entity_id)
local target = EntityGetWithTag("player_unit")[1] or 0
local r_x,r_y = EntityGetTransform(parent_id)
local t_x,t_y = EntityGetTransform(target)

if target ~= 0 then

    --Line of Sight check
    local hit = RaytraceSurfaces(r_x, r_y - 10, t_x, t_y - 6)
    if not hit and IsInvisible( target ) == false then
        r_x = r_x + math.random(-50,50)
        r_y = r_y + math.random(-50,50)
        local proj_filepath = "mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/projectiles/fire_wand_ghastly.xml"
        local proj_id = EntityLoad(proj_filepath,r_x,r_y)
        GameShootProjectile( parent_id, r_x, r_y, t_x, t_y, proj_id)

        local taunt_voicelines = {"The bigger they are..","BRING THEM DOWN!","BEGONE!"}

        local brain_id = EntityGetWithName("felcesis_brain") or 0
        if brain_id > 0 then
            local brain_vsc_comp = EntityGetFirstComponentIncludingDisabled(brain_id,"VariableStorageComponent") or 0
            ComponentSetValue2(brain_vsc_comp,"value_string",taunt_voicelines[math.random(1,#taunt_voicelines)])
            local phantom_tier = ComponentGetValue2(brain_vsc_comp,"value_float")
            local wand_vsc_comp = EntityGetFirstComponentIncludingDisabled(proj_id,"VariableStorageComponent")
            ComponentSetValue2(wand_vsc_comp,"value_float",phantom_tier)
        end
		GamePlaySound( "data/audio/Desktop/animals.bank", "animals/statue/appear", r_x, r_y );
    end
end
