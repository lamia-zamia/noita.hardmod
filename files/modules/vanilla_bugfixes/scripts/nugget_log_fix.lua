local entity_id = GetUpdatedEntityID()
local value = 0
local is_bloody = false

for _,varcomp in ipairs(EntityGetComponent(entity_id, "VariableStorageComponent") or {}) do
    if ComponentGetValue2(varcomp, "name") == "gold_value" then
        value = ComponentGetValue2(varcomp, "value_int")
    elseif ComponentGetValue2(varcomp, "name") == "hp_value" and ComponentGetValue2(varcomp, "value_float") > 0 then
        is_bloody = true
    end
end

local player = EntityGetWithTag("player_unit")[1]
if not player then return end
value = value * 2^GameGetGameEffectCount(player, "EXTRA_MONEY")

local name = GameTextGet(is_bloody and "$hardmod_bloody_nugget_pickup_name" or "$hardmod_gold_nugget_pickup_name", tostring(value))
for _,itemcomp in ipairs(EntityGetComponent(entity_id, "ItemComponent") or {}) do
    ComponentSetValue2(itemcomp, "item_name", name)
end