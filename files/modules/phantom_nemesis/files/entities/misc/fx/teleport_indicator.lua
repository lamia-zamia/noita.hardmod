local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform(entity_id)

local vsc_comp = EntityGetFirstComponentIncludingDisabled(entity_id,"VariableStorageComponent")
if not vsc_comp then return end

local master_id = ComponentGetValue2(vsc_comp,"value_int")
local physbody_comp = EntityGetFirstComponentIncludingDisabled(master_id,"PhysicsBody2Component")

local _, _, rot, scale_x, scale_y = EntityGetTransform(master_id)

if physbody_comp then
    PhysicsComponentSetTransform( physbody_comp, pos_x, pos_y, rot, 0, 0, 0)
else
    EntitySetTransform(master_id, pos_x, pos_y, rot, scale_x, scale_y)
end
GamePlaySound( "data/audio/Desktop/misc.bank", "misc/teleport_use", pos_x, pos_y )
EntityKill(entity_id)
