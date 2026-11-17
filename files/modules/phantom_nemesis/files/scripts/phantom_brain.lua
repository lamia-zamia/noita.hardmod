local entity_id = GetUpdatedEntityID()
local root_id = EntityGetRootEntity(entity_id)
local pos_x, pos_y = EntityGetTransform(entity_id)
local vsc_comp = EntityGetFirstComponentIncludingDisabled(entity_id,"VariableStorageComponent") or 0
local vsc_comp2 = EntityGetFirstComponentIncludingDisabled(entity_id,"VariableStorageComponent") or 0
local tier = ComponentGetValue2(vsc_comp,"value_float")
local last_pheromone_hint_cd = ComponentGetValue2(vsc_comp2,"value_int")

local function RecreateOriginalHost(host_id)
    local filepath = EntityGetFilename(host_id)
    EntityLoad(filepath,pos_x,pos_y)
end

local function BanishFelcesisEarly()
    local phantom_anger = tonumber(GlobalsGetValue("felcesis_anger","0"))
    GlobalsSetValue("felcesis_anger",tostring(phantom_anger+1))
    -- local damagemodel_comp = EntityGetFirstComponentIncludingDisabled(root_id,"DamageModelComponent")
    -- local hp_max = ComponentGetValue2(damagemodel_comp,"max_hp")
    -- ComponentSetValue2(damagemodel_comp,"hp",0.04)
    -- EntityInflictDamage(root_id,hp_max,"DAMAGE_CURSE","","NONE",0,0,root_id)
    RecreateOriginalHost(root_id)
    EntityKill(root_id)
    GamePrint(GameTextGet("$hardmod_phantom_enraged",GameTextGetTranslatedOrNot("$hardmod_phantom_phantom_name")))
    GamePlaySound( "data/audio/Desktop/event_cues.bank", "event_cues/angered_the_gods/create", pos_x, pos_y )
    GameScreenshake( 150 )
end

local function RemoveOldFelcesis() --There can only be one!!!
    local this_spawntime = ComponentGetValue2(vsc_comp,"value_int")
    local suspects = EntityGetWithTag("felcesis_possessed") or {}
    for _,suspect in ipairs(suspects) do
        local children = EntityGetAllChildren(suspect) or {}
        for _,child in ipairs(children) do
            if EntityGetName(child) == "felcesis_brain" then
                local suspect_vsc = EntityGetFirstComponentIncludingDisabled(child,"VariableStorageComponent") or 0
                local suspect_spawntime = ComponentGetValue2(suspect_vsc,"value_int") or 0
                if EntityGetIsAlive(suspect) and suspect_spawntime < this_spawntime then
                    EntityKill(suspect)
                    RecreateOriginalHost(suspect)
                end
            end
        end

    end
end

local function GetPlayer()
  local tags = {"player_unit", "polymorphed_player", "polymorphed_cessation"}
	for tag=1,#tags do
		local player = EntityGetWithTag(tags[tag])
		if #player > 0 then
			return player[1]
		end
	end
  return nil
end

local function PriortisePlayerAsTarget()
    local player_id = GetPlayer()
    if not player_id then return end
    local player_x, player_y = EntityGetTransform(player_id)

    local animal_ai_comp = EntityGetFirstComponentIncludingDisabled(root_id,"AnimalAIComponent")
    local pathfinding_comp = EntityGetFirstComponentIncludingDisabled(root_id,"PathFindingComponent")
    local physics_ai_comp = EntityGetFirstComponentIncludingDisabled(root_id,"PhysicsAIComponent")
    local worm_ai_comp = EntityGetFirstComponentIncludingDisabled(root_id,"WormAIComponent")

    if animal_ai_comp then
        --ComponentSetValue2(pathfinding_comp,"path_next_node_vector_to",player_x,player_y)
        ComponentSetValue2(animal_ai_comp,"creature_detection_range_x",300)
        ComponentSetValue2(animal_ai_comp,"creature_detection_range_y",300)
        ComponentSetValue2(animal_ai_comp,"creature_detection_angular_range_deg",180)
        ComponentSetValue2(animal_ai_comp,"creature_detection_check_every_x_frames",60)
        ComponentSetValue2(animal_ai_comp,"sense_creatures_through_walls",true)
    end

    if animal_ai_comp and physics_ai_comp then
        local boss_ai_comp = EntityGetFirstComponentIncludingDisabled(root_id,"LimbBossComponent")
        if boss_ai_comp then
            ComponentSetValue2(boss_ai_comp, "mMoveToPositionX", player_x)
            ComponentSetValue2(boss_ai_comp, "mMoveToPositionY", player_y)
        else
            EntityAddComponent2(root_id, "LimbBossComponent", {
                state=1
            })
        end
    end

    if worm_ai_comp then
        ComponentSetValue2(worm_ai_comp,"mTargetEntityId",player_id)
    end
end

local function BrainUpdate()
    if tier >= 4 then
        --Becomes immune to pheromone at tier 4 and above
        local comp = GameGetGameEffect( root_id, "CHARM" )
        if comp ~= 0 then
            ComponentSetValue2( comp, "effect", "NONE")
            if last_pheromone_hint_cd + 1800 < GameGetFrameNum() then
                GamePrint(GameTextGet("$hardmod_phantom_pheromone_resist",GameTextGetTranslatedOrNot("$hardmod_phantom_phantom_name")))
                ComponentSetValue2(vsc_comp2,"value_int",GameGetFrameNum())
            end
        end
    else
        --Can be immediately killed with pheromone before tier 4 at the cost of angering it
        local charmTest = GameGetGameEffectCount( root_id, "CHARM" )
        if charmTest >= 1 then
            BanishFelcesisEarly()
            return
        end
    end
    PriortisePlayerAsTarget()
    if GameGetFrameNum() % 60 == 0 then
        RemoveOldFelcesis()
    end
end

BrainUpdate()
