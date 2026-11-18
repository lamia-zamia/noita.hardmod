local function SpeedUpEnemy(entity_id,speed_mult)
    if EntityHasTag(entity_id,"spedup") == false and EntityHasTag(entity_id,"player_unit") == false then
        --local c = EntityLoad("mods/conga_fast_enemies/files/enemy_speed.xml",pos_x,pos_y)
        --EntityAddChild(entity_id,c)
        EntityAddTag(entity_id,"spedup")

        local animalcomp = EntityGetFirstComponentIncludingDisabled(entity_id,"AnimalAIComponent")
        if animalcomp ~= nil then
            ComponentSetValue2(animalcomp,"attack_ranged_frames_between", math.floor(ComponentGetValue2(animalcomp,"attack_ranged_frames_between") / speed_mult))
            --ComponentSetValue2(animalcomp,"attack_ranged_aim_rotation_speed", math.floor(ComponentGetValue2(animalcomp,"attack_ranged_aim_rotation_speed") * speed_mult))

            local aiattacks = EntityGetComponentIncludingDisabled(entity_id,"AIAttackComponent") or {}
            for z=1,#aiattacks do
                local aiattackcomp = aiattacks[z]
                ComponentSetValue2(aiattackcomp,"frames_between", math.floor(ComponentGetValue2(aiattackcomp,"frames_between") / speed_mult))
                ComponentSetValue2(aiattackcomp,"frames_between_global", math.floor(ComponentGetValue2(aiattackcomp,"frames_between_global") / speed_mult))
                ComponentSetValue2(aiattackcomp,"attack_ranged_aim_rotation_speed", math.min(ComponentGetValue2(aiattackcomp,"attack_ranged_aim_rotation_speed") * speed_mult,1))
            end
        end

        local charplatformcomp = EntityGetFirstComponentIncludingDisabled(entity_id,"CharacterPlatformingComponent")
        if charplatformcomp ~= nil then
            ComponentSetValue2(charplatformcomp,"run_velocity", ComponentGetValue2(charplatformcomp,"run_velocity") * speed_mult)
            ComponentSetValue2(charplatformcomp,"fly_velocity_x", ComponentGetValue2(charplatformcomp,"fly_velocity_x") * speed_mult)
            ComponentSetValue2(charplatformcomp,"fly_speed_max_up", ComponentGetValue2(charplatformcomp,"fly_speed_max_up") * speed_mult)
            ComponentSetValue2(charplatformcomp,"fly_speed_max_down", ComponentGetValue2(charplatformcomp,"fly_speed_max_down") * speed_mult)
            ComponentSetValue2(charplatformcomp,"velocity_max_x", ComponentGetValue2(charplatformcomp,"velocity_max_x") * speed_mult)
            ComponentSetValue2(charplatformcomp,"velocity_max_y", ComponentGetValue2(charplatformcomp,"velocity_max_y") * speed_mult)
            ComponentSetValue2(charplatformcomp,"jump_velocity_x", ComponentGetValue2(charplatformcomp,"jump_velocity_x") * speed_mult)
            ComponentSetValue2(charplatformcomp,"jump_velocity_y", ComponentGetValue2(charplatformcomp,"jump_velocity_y") * speed_mult)
            ComponentSetValue2(charplatformcomp,"fly_speed_mult", ComponentGetValue2(charplatformcomp,"fly_speed_mult") * speed_mult)
            ComponentSetValue2(charplatformcomp,"fly_smooth_y",false)
        end

        --We cap speed mults to 20 here since without the cap, physics & worm enemies instantly teleport into unloaded terrain upon spawning in

        local wormaicomp = EntityGetFirstComponentIncludingDisabled(entity_id,"WormAIComponent")
        if wormaicomp ~= nil then
            ComponentSetValue2(wormaicomp,"speed", math.ceil(ComponentGetValue2(wormaicomp,"speed") * math.min(speed_mult,20)))
            ComponentSetValue2(wormaicomp,"speed_hunt", math.ceil(ComponentGetValue2(wormaicomp,"speed_hunt") * math.min(speed_mult,20)))
            ComponentSetValue2(wormaicomp,"direction_adjust_speed", ComponentGetValue2(wormaicomp,"direction_adjust_speed") * math.min(speed_mult,20))
            ComponentSetValue2(wormaicomp,"direction_adjust_speed_hunt", ComponentGetValue2(wormaicomp,"direction_adjust_speed_hunt") * math.min(speed_mult,20))
        end

        local ghostcomp = EntityGetFirstComponentIncludingDisabled(entity_id,"GhostComponent")
        if ghostcomp ~= nil then
            ComponentSetValue2(ghostcomp,"speed", math.ceil(ComponentGetValue2(ghostcomp,"speed") * math.min(speed_mult,20)))
        end

        local wormcomp = EntityGetFirstComponentIncludingDisabled(entity_id,"WormComponent")
        if wormcomp ~= nil then
            ComponentSetValue2(wormcomp,"acceleration", ComponentGetValue2(wormcomp,"acceleration") * math.min(speed_mult,20))
        end

        local dragoncomp = EntityGetFirstComponentIncludingDisabled(entity_id,"BossDragonComponent")
        if dragoncomp ~= nil then
            ComponentSetValue2(dragoncomp,"speed", math.ceil(ComponentGetValue2(dragoncomp,"speed") * math.min(speed_mult,20)))
            ComponentSetValue2(dragoncomp,"speed_hunt", math.ceil(ComponentGetValue2(dragoncomp,"speed_hunt") * math.min(speed_mult,20)))
            ComponentSetValue2(dragoncomp,"direction_adjust_speed", ComponentGetValue2(dragoncomp,"direction_adjust_speed") * math.min(speed_mult,20))
            ComponentSetValue2(dragoncomp,"direction_adjust_speed_hunt", ComponentGetValue2(dragoncomp,"direction_adjust_speed_hunt") * math.min(speed_mult,20))
            ComponentSetValue2(dragoncomp,"acceleration", ComponentGetValue2(dragoncomp,"acceleration") * math.min(speed_mult,20))
        end

        local paicomp = EntityGetFirstComponentIncludingDisabled(entity_id,"PhysicsAIComponent")
        if paicomp ~= nil then
            ComponentSetValue2(paicomp,"force_coeff", ComponentGetValue2(paicomp,"force_coeff") * math.min(speed_mult,20))
            ComponentSetValue2(paicomp,"force_max", ComponentGetValue2(paicomp,"force_max") * math.min(speed_mult,20))
            ComponentSetValue2(paicomp,"torque_coeff", ComponentGetValue2(paicomp,"torque_coeff") * math.min(speed_mult,20))
            ComponentSetValue2(paicomp,"torque_max", ComponentGetValue2(paicomp,"torque_max") * math.min(speed_mult,20))
            ComponentSetValue2(paicomp,"target_vec_max_len", ComponentGetValue2(paicomp,"target_vec_max_len") * math.min(speed_mult,20))
        end
    end
end

SpeedUpEnemy(GetUpdatedEntityID(),2)
