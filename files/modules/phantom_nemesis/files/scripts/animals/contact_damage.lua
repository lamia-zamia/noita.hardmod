if ComponentGetValue2(GetUpdatedComponentID(), "mTimesExecuted") <= 3 then return end
-- ^skip damage first 3 times (starts damage on frame 160f (~2.5s))

local entity_id = EntityGetRootEntity(GetUpdatedEntityID())
if entity_id == GetUpdatedEntityID() then EntityKill(GetUpdatedEntityID()) end
local pos_x, pos_y = EntityGetTransform(entity_id)
local radius = 64
local genome_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "GenomeDataComponent")
if not genome_comp then return end
local genome = ComponentGetValue2(genome_comp, "herd_id")
local targets = EntityGetInRadiusWithTag(pos_x, pos_y, radius, "mortal")
for _,target in ipairs (targets) do
    local genome_compb = EntityGetFirstComponentIncludingDisabled(target, "GenomeDataComponent")
    if genome_compb then
        local genomeb = ComponentGetValue2(genome_compb, "herd_id")
		local dmg_comp = EntityGetFirstComponentIncludingDisabled(target, "DamageModelComponent")
        if dmg_comp and GetHerdRelation(genome, genomeb) < 75 then
            local hp_max = ComponentGetValue2(dmg_comp, "max_hp")
            EntityInflictDamage(target, hp_max * 0.03, "DAMAGE_PROJECTILE", "$streamingevent_areadamage_enemy", "NONE", 0, 0, entity_id)
        end
    end
end
