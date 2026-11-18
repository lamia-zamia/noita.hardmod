local module_id = GetUpdatedEntityID()
local host_id = EntityGetRootEntity(module_id)
local pos_x, pos_y = EntityGetTransform(host_id)
local teleportation_data = EntityGetFirstComponentIncludingDisabled(module_id,"VariableStorageComponent")
if not teleportation_data then return end

--Teleportation data
local next_teleport_frame = ComponentGetValue2(teleportation_data,"value_int")
local teleportation_cooldown = 1800
local tele_distance_from_target = 128
local current_frame = GameGetFrameNum()

function GetPlayer()
  local tags = {"player_unit", "polymorphed_player", "polymorphed_cessation"}
	for tag=1,#tags do
		local player = EntityGetWithTag(tags[tag])
		if #player > 0 then
			return player[1]
		end
	end
  return nil
end

function GetDistanceFromTarget(entity_id,victim_id)
  if victim_id == 0 or victim_id == nil then return 0 end
  local x,y = EntityGetTransform(entity_id)
  local v_x,v_y = EntityGetTransform(victim_id)
  local distance = math.abs(v_y - y) + math.abs(v_x - x)
  return distance or 0
end

function SetTeleportLocation()
    local current_target = GetPlayer()
    local distance_from_target = GetDistanceFromTarget(host_id,current_target)
    if not current_target or distance_from_target < 128 or distance_from_target > 800 or IsInvisible(current_target) then return end
    SetRandomSeed(pos_x+current_frame,pos_y)
    if EntityGetIsAlive(current_target) == false and current_target ~= 0 then return end
    local t_x,t_y = EntityGetTransform(current_target)
    local angle = math.rad(Random(0,359))

    local did_hit = false
    local tele_x = t_x + math.cos(angle) * tele_distance_from_target
    local tele_y = t_y - math.sin(angle) * tele_distance_from_target

    did_hit, tele_x, tele_y = RaytracePlatforms(t_x, t_y, tele_x, tele_y)
    local currbiome = BiomeMapGetName(tele_x, tele_y)
    if currbiome == "$biome_holymountain" then return end --Do not follow the player into the holy mountain, the gods wouldn't like that

    local eid = EntityLoad("mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/misc/fx/teleport_indicator.xml",tele_x,tele_y)
    local tele_vsc = EntityGetFirstComponentIncludingDisabled(eid,"VariableStorageComponent")
	if tele_vsc then
		ComponentSetValue2(tele_vsc,"value_int",host_id)
	end

    --Teleport indication
    GamePlaySound("data/audio/Desktop/misc.bank", "misc/teleport_use", tele_x, tele_y)
    local ring_eid = EntityLoad("mods/noita.hardmod/files/modules/phantom_nemesis/files/particles/indicator_ring.xml", tele_x, tele_y)
    local particle_comp = EntityGetFirstComponentIncludingDisabled(ring_eid,"ParticleEmitterComponent")
	if particle_comp then
		ComponentSetValue2(particle_comp,"emitted_material_name","spark_blue_dark")
	end

    --Set teleport CD
    ComponentSetValue2(teleportation_data,"value_int",current_frame + teleportation_cooldown)
end

if current_frame >= next_teleport_frame then
    SetTeleportLocation()
end
