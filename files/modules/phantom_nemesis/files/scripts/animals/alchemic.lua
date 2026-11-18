
local entity_id = GetUpdatedEntityID()
local parent_id = EntityGetParent(entity_id)
local target = EntityGetWithTag("player_unit")[1] or 0
local r_x,r_y = EntityGetTransform(parent_id)
local t_x,t_y = EntityGetTransform(target)

if target ~= 0 then

    --Line of Sight check
    local hit = RaytraceSurfaces(r_x, r_y - 10, t_x, t_y - 6)
    if not hit and IsInvisible(target) == false then
        local proj_filepath = "mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/projectiles/potion_alchemist.xml"
        GameShootProjectile(parent_id, r_x, r_y, t_x, t_y, EntityLoad(proj_filepath,r_x,r_y))

        EntitySetDamageFromMaterial(parent_id, "lava", 0)
        EntitySetDamageFromMaterial(parent_id, "acid", 0)
        EntitySetDamageFromMaterial(parent_id, "poison", 0)
    end
end
