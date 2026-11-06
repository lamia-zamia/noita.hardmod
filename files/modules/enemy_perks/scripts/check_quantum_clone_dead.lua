local entity_id = GetUpdatedEntityID()
local component = GetUpdatedComponentID()

local shared_clone_id = ComponentGetValue2(component, "limit_how_many_times_per_frame")
local target_clone_num = ComponentGetValue2(component, "limit_to_every_n_frame")

print("clone running gang check: "..entity_id)
print("shared_clone_id: "..shared_clone_id)
print("target_clone_num: "..target_clone_num)

local members = {entity_id}
print("running check for members...")
print("initial member: ".. entity_id)
for _,enemy in ipairs(EntityGetWithTag("hardmod_blessed")) do
    print("checking "..enemy.."...")
    if enemy == entity_id then print("skipping self...") goto check_next_enemy end
    for _,varcomp in ipairs(EntityGetComponent(enemy, "VariableStorageComponent") or {}) do
        print("checking varcomp: "..varcomp)
        if ComponentGetValue2(varcomp, "name") == "hardmod_quantum_clone_data" then
            local clone_id = ComponentGetValue2(varcomp, "value_int")
            if clone_id == shared_clone_id then members[#members+1] = enemy print("found member: "..enemy) end
            print("found clone with id: "..clone_id)
            goto check_next_enemy
        end
    end
    ::check_next_enemy::
end

if #members ~= target_clone_num then
    print(("members is %s, expected %s"):format(#members, target_clone_num))
    print("FAILURE IS "..entity_id)
    for _,member in ipairs(members) do
        --EntityKill(member)
    end
else
    print("success! we live another day")
end

function death(damage_type_bit_field, message, attacker, drop_items)
    for _,member in ipairs(members) do
        EntityKill(member)
    end
end

print("gang check over\n ")