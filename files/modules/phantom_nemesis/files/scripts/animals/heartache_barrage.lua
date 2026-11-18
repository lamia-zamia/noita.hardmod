
local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent(entity_id)
local target = EntityGetWithTag("player_unit")[1] or 0
local r_x, r_y = EntityGetTransform(parent_id)
local t_x, t_y = EntityGetTransform(target)

if target ~= 0 then
    --Line of Sight check
    local hit = RaytraceSurfaces(r_x, r_y - 10, t_x, t_y - 6)
    if not hit and IsInvisible(target) == false then
        local p_x = t_x + math.random(-96, 96)
        local p_y = t_y + math.random(-48, 48)
        local proj_filepath = "mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/projectiles/heartache_portal.xml"
        local proj_id = EntityLoad(proj_filepath, p_x, p_y)
        local vsc_comp = EntityGetFirstComponentIncludingDisabled(proj_id, "VariableStorageComponent")
		if vsc_comp then
			ComponentSetValue2(vsc_comp, "value_int", GameGetFrameNum())
		end

        EntityAddTag(proj_id, "projectile_cloned")
        GameShootProjectile(parent_id, p_x, p_y, t_x, t_y, proj_id)
        math.randomseed(r_x+t_y*t_x+r_y)

        local taunt_voicelines = {"The bigger they are..", "BRING THEM DOWN!", "INSIGNIFICANT HUSK!"}

        local brain_id = EntityGetWithName("felcesis_brain") or 0
        if brain_id > 0 then
            local brain_vsc_comp = EntityGetFirstComponentIncludingDisabled(brain_id, "VariableStorageComponent")
			if brain_vsc_comp then
				ComponentSetValue2(brain_vsc_comp, "value_string", taunt_voicelines[math.random(1, #taunt_voicelines)])
			end
        end
		GamePlaySound("data/audio/Desktop/animals.bank", "animals/statue/appear", p_x, p_y)
    end
end
