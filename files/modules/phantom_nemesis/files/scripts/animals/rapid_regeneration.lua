local ability_id = GetUpdatedEntityID()
local host_id = EntityGetRootEntity(GetUpdatedEntityID())
if host_id == GetUpdatedEntityID() then EntityKill(ability_id) end
local pos_x,pos_y = EntityGetTransform(host_id)
local dmg_comp = EntityGetFirstComponentIncludingDisabled(host_id,"DamageModelComponent")

if not dmg_comp then return end

local hp_max = ComponentGetValue2(dmg_comp,"max_hp")
local hp = ComponentGetValue2(dmg_comp,"hp")

local vsc_comp = EntityGetFirstComponentIncludingDisabled(ability_id,"VariableStorageComponent")
if not vsc_comp then return end

local frame_regeneration_started_on = ComponentGetValue2(vsc_comp,"value_int")
local current_frame = GameGetFrameNum()
local regeneration_duration = 60
if hp < hp_max * 0.4 and frame_regeneration_started_on == 0 then
    ComponentSetValue2(vsc_comp,"value_int",current_frame)
    EntityAddChild(host_id,EntityLoad("data/entities/misc/effect_regeneration.xml",0,0))
elseif frame_regeneration_started_on > 0 then
    EntityInflictDamage(host_id, (hp_max * 0.01)*-1, "DAMAGE_HEALING", "$streamingevent_areadamage_enemy", "NONE", 0, 0, host_id)
    if current_frame > frame_regeneration_started_on + regeneration_duration then
        EntityKill(ability_id)
    end
end
