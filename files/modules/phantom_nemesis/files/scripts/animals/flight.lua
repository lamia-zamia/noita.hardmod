
local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent(entity_id)

local acomp = EntityGetFirstComponentIncludingDisabled(parent_id,"AnimalAIComponent")
if acomp then
    ComponentSetValue2(acomp,"can_fly",true)
end

local pcomp = EntityGetFirstComponentIncludingDisabled(parent_id,"PathFindingComponent")
if pcomp then
    ComponentSetValue2(pcomp,"can_fly",true)
    ComponentSetValue2(pcomp,"can_walk",false)
end

local wcomp = EntityGetFirstComponentIncludingDisabled(parent_id,"WormComponent")
if wcomp then
    ComponentSetValue2(wcomp,"gravity",0)
    ComponentSetValue2(wcomp,"tail_gravity",0)
    ComponentSetValue2(wcomp,"is_water_worm",false)
end

local hitbox_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "HitboxComponent")
local hitbox_feet_y = 2
local hitbox_feet_width = 4
if hitbox_comp then
    hitbox_feet_y = ComponentGetValue2(hitbox_comp, "aabb_max_y")
    hitbox_feet_width = ComponentGetValue2(hitbox_comp,"aabb_max_x") + 2
end

EntityAddComponent2(entity_id,"ParticleEmitterComponent",{
    emitted_material_name="spark_blue_dark",
    lifetime_min=0.6,
    lifetime_max=0.8,
    count_min=4,
    count_max=8,
    render_on_grid=true,
    fade_based_on_lifetime=true,
    airflow_force=0.1,
    airflow_scale=0.1,
    airflow_time=0.6,
    emission_interval_min_frames=1,
    emission_interval_max_frames=2,
    emit_cosmetic_particles=true,
    x_vel_min=0,
    x_vel_max=0,
    y_vel_min=0,
    y_vel_max=10,
    x_pos_offset_min=hitbox_feet_width,
    x_pos_offset_max=hitbox_feet_width*-1,
    y_pos_offset_min=hitbox_feet_y,
    y_pos_offset_max=hitbox_feet_y+1,
    
})

EntityAddTag(parent_id,"flying")
