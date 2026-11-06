local abilities_list = {
    {
        tier = 1,
        abilities = {{id="alchemic",cost=100},{id="summoner",cost=200},{id="homing_shoot",cost=200},{id="suppressive",cost=200},{id="slime_aura",cost=50},{id="haste",cost=150},{id="contact_damage",cost=100}}
    },
    {
        tier = 2,
        abilities = {{id="ghastly",cost=200},{id="immune_explosion",cost=200},{id="immune_electricity",cost=200},{id="immune_melee",cost=200},{id="immune_fire",cost=200},{id="immune_ice",cost=200},{id="immune_radioactive",cost=200},{id="immune_drill",cost=200},{id="immune_curse",cost=200},{id="immune_holy",cost=200},{id="shield_big",cost=150},{id="barrage_shoot",cost=200},{id="necrobot",cost=300},{id="poison_blood",cost=100},{id="immune_stun",cost=200}}
    },
    {
        tier = 3,
        abilities = {{id="shield_reactive",cost=200},{id="rapid_regeneration",cost=200},{id="anti_ambrosia_field",cost=300},{id="flight",cost=50},{id="teleport_to_target",cost=500},{id="matter_eater",cost=300}}
    },
    {
        tier = 4,
        abilities = {{id="immune_projectile",cost=400},{id="neutral_shoot",cost=300},{id="vulnerability_shoot",cost=300}}
    },
    {
        tier = 5,
        abilities = {{id="corrupted",cost=300},{id="boss_protections",cost=400},{id="heartache_barrage",cost=300},{id="wounded_shoot",cost=400}}
    }
}

local context_checks = {
    {
        id = "has_animalaicomp",
        check = function(entity_id)
            local animal_ai_comp = EntityGetFirstComponentIncludingDisabled(entity_id,"AnimalAIComponent") or 0
            if animal_ai_comp > 0 then return true end
            return false
        end
    },
    {
        id = "has_physicsbody",
        check = function(entity_id)
            local physics_body_comp = EntityGetFirstComponentIncludingDisabled(entity_id,"PhysicsImageShapeComponent") or 0
            if physics_body_comp > 0 then return true end
            return false
        end
    },
    {
        id = "is_worm",
        check = function(entity_id)
            local worm_comp = EntityGetFirstComponentIncludingDisabled(entity_id,"WormComponent") or 0
            if worm_comp > 0 then return true end
            return false
        end
    },
    {
        id = "has_ranged_attack",
        check = function(entity_id)
            local animal_ai_comp = EntityGetFirstComponentIncludingDisabled(entity_id,"AnimalAIComponent") or 0
            if animal_ai_comp > 0 then
                if ComponentGetValue2(animal_ai_comp,"attack_ranged_enabled") then return true end
                return false
            end
            return false
        end
    },
    {
        id = "can_fly",
        check = function(entity_id)
            if EntityHasTag(entity_id,"flying") == true then return true end
            local worm_comp = EntityGetFirstComponentIncludingDisabled(entity_id,"WormComponent") or 0
            if worm_comp > 0 then
                if ComponentGetValue2(worm_comp,"gravity") == 0 or ComponentGetValue2(worm_comp,"tail_gravity") == 0 then
                    return true
                end
            end
            return false
        end
    },
    {
        id = "player_immunity_perks",
        check = function(entity_id)
            local player_id = EntityGetWithTag("player_unit")[1] or 0
            local protective_perk_count = 0
            if player_id > 0 then
                local children = EntityGetAllChildren( player_id ) or {}
                for _,child in ipairs(children) do
                    if EntityHasTag(child,"effect_protection") then protective_perk_count = protective_perk_count + 1 end
                end
            end
            return protective_perk_count
        end
    },
    {
        id = "player_shield_count",
        check = function(entity_id)
            local player_id = EntityGetWithTag("player_unit")[1] or 0
            local shield_perk_count = 0
            if player_id > 0 then
                local children = EntityGetAllChildren( player_id ) or {}
                for _,child in ipairs(children) do
                    if EntityHasTag(child,"energy_shield") then shield_perk_count = shield_perk_count + 1 end
                end
            end
            return shield_perk_count
        end
    },
    {
        id = "most_taken_damage_type",
        check = function(entity_id)
            local damage_types_can_resist = {"projectile","electricity","explosion","fire","melee","drill","slice","ice","radioactive","curse","holy"}
            local most_desirable_to_resist = {id="projectile",damage=0}
            for k=1,#damage_types_can_resist do
                local damage_taken = tonumber(GlobalsGetValue(table.concat({"felcesis_damage_taken_from_",damage_types_can_resist[k],}),"0"))
                if damage_taken > most_desirable_to_resist.damage then
                    most_desirable_to_resist.id = damage_types_can_resist[k]
                    most_desirable_to_resist.damage = damage_taken
                end
            end
            return most_desirable_to_resist.id
        end
    },
    {
        id = "banishment_ratio",
        check = function ()
            local total_possessions = GlobalsGetValue("felcesis_total_possessions","0")
            local total_deaths = tonumber(GlobalsGetValue("felcesis_last_deaths","0"))
            --This represents how many times the player has run from Felcesis vs how many times they've fought them head-on
            --If the ratio of possessions:deaths is 1:1, then it means the player has always fought and killed felcesis each time they've appeared
            --If the ratio of possessions:deaths is 5:1, then it means the player is four times as likely to run from felcesis than they are to fight them
            --The idea is if the player is likely to flee from felcsis then felcesis will prioritise taking abilities which let them chase the player down
            --However if the player is likely to fight felcesis then felcesis wont waste budget on buying things like teleport_to_target
            if total_deaths == 0 or total_possessions == 0 then return 100 end
            local repossession_ratio = total_possessions/total_deaths
            return repossession_ratio
        end
    }
}

function IsValidEnemy( file )
	local test = "data/entities/animals/"
	
	if ( string.sub( file, 1, #test ) == test ) then
		return true
	end
	
	return false
end

local function BuildContext(entity_id)
    local context = {}
    for _, context_check in ipairs(context_checks) do
        context[context_check.id] = context_check.check(entity_id)
    end
    return context
end

local function GetAbilityWeight(ability_id, context, tier)
    local weight = 1.0

    local has_animalaicomp = context.has_animalaicomp
    local has_physicsbody = context.has_physicsbody
    local is_worm = context.is_worm
    local has_ranged = context.has_ranged_attack
    local can_fly = context.can_fly
    local immunity_perks = context.player_immunity_perks
    local player_shield_count = context.player_shield_count
    local most_taken_damage_type = context.most_taken_damage_type
    local banishment_ratio = context.banishment_ratio

    local weight_considerations = {
        {
            affected_abilities = {"vulnerability_shoot"},
            weight_change = function()
                if immunity_perks > 0 then
                    --Felcesis becomes more likely to purchase the vulnerability status effect on hit the more immunity perks the player has
                    weight = weight * (1 + (immunity_perks * 1.5))
                end
            end
        },
        {
            affected_abilities = {"barrage_shoot"},
            weight_change = function()
                weight = weight * 1+player_shield_count
            end
        },
        {
            affected_abilities = {"homing_shoot","barrage","suppressive","vulnerability_shoot","neutral_shoot","wounded_shoot"},
            weight_change = function()
                if has_ranged == false then
                    weight = 0.01 --No point giving a new scope to a man without a gun
                end
            end
        },
        {
            affected_abilities = {"contact_damage","ghastly","alchemic"},
            weight_change = function(ability_id)
                if has_ranged == false then
                    weight = weight * 2 --You can give him a new knife though
                elseif ability_id == "contact_damage" then
                    weight = weight * 0.35
                end
            end
        },
        {
            affected_abilities = {"corrupted","suppressive"},
            weight_change = function()
                if has_animalaicomp == false then
                    weight = 0.01 --These abilities would break if the target entity doesn't have an animal ai comp
                end
            end
        },
        {
            affected_abilities = {"flight"},
            weight_change = function()
                if can_fly then
                    weight = 0.01 --No point giving the gift of flight to a bird
                else
                    weight = weight * 20 --The enemy should definitely be able to fly in order to keep up with the player late into a run
                end
            end
        },
        {
            affected_abilities = {"matter_eater"},
            weight_change = function ()
                if can_fly and is_worm == false then
                    weight = weight * 8
                elseif tier <3 or is_worm then
                    weight = weight * 0.01
                end
            end
        },
        {
            affected_abilities = {"boss_protections"},
            weight_change = function()
                weight = weight * 10
            end
        },
        {
            affected_abilities = {"immune_stun"},
            weight_change = function()
                weight = weight * tier
            end
        },
        {
            affected_abilities = {"poison_blood"}, --Felcesis chooses this one way too often, chill brother
            weight_change = function ()
                weight = weight * 0.35
            end
        },
        {
            affected_abilities = {"immune_projectile","immune_explosion","immune_electricity","immune_melee","immune_fire","immune_ice","immune_radioactive","immune_drill","immune_curse","immune_holy"},
            weight_change = function(ability_id) --Felcesis will prioritize purchasing immunities to the damage type you're using against him the most
                if table.concat({"immune_",most_taken_damage_type}) == ability_id then
                    weight = weight * 100
                else
                    weight = weight * 0.02
                end
            end
        },
        {
            affected_abilities = {"haste","teleport_to_target"},
            weight_change = function (ability_id)
                local ratio_required = 2
                if ability_id == "teleport_to_target" then ratio_required = 8 end
                local chase_modifier = math.max(banishment_ratio-ratio_required,0) --If the player is more than 3x (2x for haste) as likely to flee from felcesis, then start prioritising perks that let felcesis hunt the player down more easily to punish them for their cowardice
                weight = weight * chase_modifier
            end
        },
        {
            affected_abilities = {"necrobot"},
            weight_change = function ()
                local x,y = EntityGetTransform(GetUpdatedEntityID())
                local targets = EntityGetInRadiusWithTag( x, y, 128, "mortal" ) or {}
                for k=1,#targets,-1 do
                    if EntityHasTag(targets[k],"player_unit") or EntityHasTag(targets[k],"necrobot_NOT") then
                        table.remove(targets,k)
                    end
                end
                weight = #targets * 0.35 --Weight necrobot usage depending on how many revivable targets are actually nearby
            end
        },
        {
            affected_abilities = {"homing_shoot"},
            weight_change = function ()
                local repulsion_field_count = tonumber(GlobalsGetValue("PERK_PICKED_PROJECTILE_REPULSION_PICKUP_COUNT","0"))
                if repulsion_field_count > 0 then
                    weight = weight * (repulsion_field_count*10)
                end
            end
        }
    }

    for _,weight_consideration in ipairs(weight_considerations) do
        for _,id in ipairs(weight_consideration.affected_abilities) do
            if id == ability_id then
                weight_consideration.weight_change(ability_id)
            end
        end
    end

    return weight
end

local function GetPossibleShoppingList(entity_id, tier, budget)
    local context = BuildContext(entity_id)
    local options = {}

    for _, tier_data in ipairs(abilities_list) do
        if tier_data.tier <= tier then
            for _, ability in ipairs(tier_data.abilities) do
                if ability.cost <= budget then
                    table.insert(options, {
                        id = ability.id,
                        cost = ability.cost,
                        tier = tier_data.tier,
                        weight = GetAbilityWeight(ability.id, context, tier) or 0
                    })
                end
            end
        end
    end

    return options
end

local function GetDistanceFromTarget(entity_id,victim_id)
  if victim_id == 0 or victim_id == nil then return 0 end
  local x,y = EntityGetTransform(entity_id)
  local v_x,v_y = EntityGetTransform(victim_id)
  local distance = math.abs(v_y - y) + math.abs(v_x - x)
  return distance or 0
end

function CreateMiniboss(entity_id, x, y, tier, budget, health_mult)
    math.randomseed(x + y)
    print("Tier: " .. tier .. " Budget: " .. budget .. " Health Mult: " .. math.floor(health_mult) .. " x: " .. math.floor(x) .. " y: " .. math.floor(y) .. " Filename: " .. EntityGetFilename(entity_id) .. "\n========================================================")
    local phantom_name = GameTextGetTranslatedOrNot("$hardmod_phantom_phantom_name") --Ira, Latin for angeeeee
    local victim_name = GameTextGetTranslatedOrNot(EntityGetName(entity_id))

    if victim_name == "" then victim_name = GameTextGetTranslatedOrNot(table.concat({"$animal_",(EntityGetFilename(entity_id):gsub("^.*/(.-)%.xml$", "%1"))})) end
    local selected_abilities_list = {}
    GamePrint(GameTextGet("$hardmod_phantom_possession",phantom_name,victim_name))

    --local filepath = EntityGetFilename(entity_id)
    if EntityGetIsAlive(entity_id) == false or IsValidEnemy(EntityGetFilename(entity_id)) == false or EntityGetName(entity_id) == "" or EntityHasTag(entity_id, "miniboss_minion") or EntityHasTag(entity_id, "helpless_animal") then return end

    local fx = {}

    local options = GetPossibleShoppingList(entity_id, tier, budget)

    while budget > 0 and #options > 0 do
        local total_weight = 0
        for _, opt in ipairs(options) do
            total_weight = total_weight + opt.weight
        end

        local rng = math.random() * total_weight
        local selected_index = 1
        local cumulative = 0
        for i, opt in ipairs(options) do
            cumulative = cumulative + opt.weight
            if rng <= cumulative then
                selected_index = i
                break
            end
        end

        local effect = table.remove(options, selected_index)

        budget = budget - effect.cost
        table.insert(fx, effect.id)

        local ability_id = EntityLoad(table.concat({"mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/misc/",effect.id,".xml"}), x, y)

        if ability_id ~= nil and ability_id ~= 0 then
            EntityAddChild(entity_id, ability_id)
            EntitySetName(ability_id,effect.id)
            table.insert(selected_abilities_list,table.concat({"hardmod_phantom_ability_",effect.id,"_name"}))
        end

        for i = #options, 1, -1 do
            if options[i].cost > budget then
                table.remove(options, i)
            end
        end
    end

    --Add Felcesis's particles & necessary tags to the possessed entity
    local brain_id = EntityLoad("mods/noita.hardmod/files/modules/phantom_nemesis/files/entities/felcesis_brain.xml", x, y)
    local brain_vsc_comp = EntityGetFirstComponentIncludingDisabled(brain_id,"VariableStorageComponent")
    ComponentSetValue2(brain_vsc_comp,"value_string",table.concat(selected_abilities_list,","))
    EntityAddChild(entity_id,brain_id)
    EntityAddTag(entity_id, "polymorphable_NOT")
    EntityAddTag(entity_id,"music_energy_100")
    EntityAddTag(entity_id,"felcesis_possessed")
    EntitySetName(entity_id,phantom_name)

    local hitbox_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "HitboxComponent") or 0
    local offset_y = -16
    local hitbox_height_y = 0
    if hitbox_comp > 0 then 
        hitbox_height_y = ComponentGetValue2(hitbox_comp, "aabb_min_y")
    end

    local brain_vsc_comp = EntityGetFirstComponentIncludingDisabled(brain_id,"VariableStorageComponent") or 0
    ComponentSetValue2(brain_vsc_comp,"value_int",GameGetFrameNum())
    ComponentSetValue2(brain_vsc_comp,"value_float",tier)

    --Dialogue
    EntityAddComponent2(brain_id,"LuaComponent",{
		_tags="enabled_in_world,enabled_in_hand,enabled_in_inventory",
		_enabled=true,
		script_source_file="mods/noita.hardmod/files/modules/phantom_nemesis/files/scripts/dialogue/phantom_dialogue.lua",
		execute_every_n_frame=1,
        execute_times=-1
    })

    --Death script
    EntityAddComponent2(entity_id,"LuaComponent",{
		_tags="enabled_in_world,enabled_in_hand,enabled_in_inventory",
		_enabled=true,
        script_death="mods/noita.hardmod/files/modules/phantom_nemesis/files/scripts/dialogue/phantom_death.lua",
        script_damage_received="mods/noita.hardmod/files/modules/phantom_nemesis/files/scripts/dialogue/phantom_death.lua",
		execute_every_n_frame=-1
    })

    local bosshealthbar_component = EntityGetFirstComponentIncludingDisabled(entity_id,"BossHealthBarComponent") or 0

    if bosshealthbar_component == 0 then
        EntityAddComponent2(
            entity_id,
            "BossHealthBarComponent",
            {
                gui = false,
                in_world = true
            }
        )

        EntityAddComponent2(
            entity_id,
            "SpriteComponent",
            {
                _tags = "health_bar_back,ui,no_hitbox",
                _enabled = true,
                alpha = 1,
                has_special_scale = true,
                image_file = "data/ui_gfx/health_slider_back_worm.png",
                offset_x = 12,
                offset_y = (hitbox_height_y + offset_y) * -1,
                ui_is_parent = false,
                update_transform = true,
                visible = true,
                z_index = -9000,
                never_ragdollify_on_death = true
            }
        )

        EntityAddComponent2(
            entity_id,
            "SpriteComponent",
            {
                _tags = "health_bar,ui,no_hitbox",
                _enabled = true,
                alpha = 1,
                has_special_scale = true,
                image_file = "data/ui_gfx/health_slider_front.png",
                offset_x = 11,
                offset_y = (hitbox_height_y + offset_y + 1) * -1,
                ui_is_parent = false,
                update_transform = true,
                visible = true,
                z_index = -9001,
                never_ragdollify_on_death = true
            }
        )
    end

    local dmgcomp = EntityGetFirstComponentIncludingDisabled(entity_id, "DamageModelComponent")
    local hp = ComponentGetValue2(dmgcomp, "max_hp")
    ComponentSetValue2(dmgcomp, "max_hp", hp * health_mult)
    ComponentSetValue2(dmgcomp, "hp", hp * health_mult)
    ComponentObjectSetValue2(dmgcomp,"damage_multipliers","physics_hit", math.max(0,1-((tier-1) * 0.4))) --Gain 40% physics damage reduction per tier, maxing out at physics damage immunity at tier 3
    if tier >= 3 then ComponentSetValue2(dmgcomp,"fire_probability_of_ignition",0) end

    local total_possessions = GlobalsGetValue("felcesis_total_possessions","0")
    GlobalsSetValue("felcesis_total_possessions",tostring(total_possessions+1))
    -- GamePrint("Creating miniboss at tier: " .. tier .. ", budget: " .. budget .. ", hpmult: " .. health_mult .. " with types " .. table.concat(fx, ", ") .. " at coordinates " .. math.floor(x) .. ", " .. math.floor(y))
    -- print("Creating miniboss at tier: " .. tier .. ", budget: " .. budget .. ", hpmult: " .. health_mult .. " with types " .. table.concat(fx, ", ") .. " at coordinates " .. math.floor(x) .. ", " .. math.floor(y))
end

function CalculateMinibossPower(biomes_visited)
    local phantom_anger = tonumber(GlobalsGetValue("felcesis_anger","0")) --Felcesis becomes more angry each time they're banished using pheromone, allows them to roll higher on their power variation with each banishment
    local random_power_variation = math.random(-2,1+phantom_anger)
    local health_softcap = 15
    biomes_visited = biomes_visited + random_power_variation
    local tier = math.max(1,math.floor(1+(biomes_visited / 4)))
    local budget = math.max(450,400 + (125 * biomes_visited))
    local hp_mult = math.max(5,1+(biomes_visited * 1.5))
    if hp_mult > health_softcap then
        hp_mult = health_softcap + (math.log(hp_mult - health_softcap + 1) * 1.5)
    end
    return {tier=tier,budget=budget,hp_mult=hp_mult}
end

function FindPossessionTarget(biomes_visited)
    local cam_x,cam_y = GameGetCameraPos()
    local possible_targets = EntityGetInRadiusWithTag(cam_x,cam_y,math.min(64+(biomes_visited*32),512),"enemy") or {}
    local strongest_target = {}
    local player_id = EntityGetWithTag("player_unit")[1] or 0
    local minimum_distance_from_player = 32 --Don't let felcesis possess an enemy right that's in the player's face, too unfair
    for _,target in ipairs(possible_targets) do
        --Filter out non-viable targets

        --if felcesis already exists, don't possess someone else, only one possession can be active at at time
        if EntityHasTag(target,"felcesis_possessed") then
            return false
        end

        if player_id > 0 then
            local distance = GetDistanceFromTarget(target,player_id)
            if distance < minimum_distance_from_player then
                goto skipthistarget
            end
        end

        --Filter by tag
        if EntityHasTag(target,"boss") or EntityHasTag(target,"miniboss") or EntityHasTag(target,"hardmod_blessed") or EntityHasTag(target,"miniboss_minion") or EntityHasTag(target,"helpless_animal") or EntityHasTag(target,"prop") or EntityHasTag(target,"polymorphed_player") or EntityHasTag(target,"polymorphed_cessation") or EntityHasTag(target,"player_unit") or EntityHasTag(target,"mortal") == false then
            goto skipthistarget
        end

        --Filter by suspicious components
        local animal_ai_comp = EntityGetFirstComponentIncludingDisabled(target,"AnimalAIComponent") or 0
        local proj_comp = EntityGetFirstComponentIncludingDisabled(target,"ProjectileComponent") or 0
        local lifetime_comp = EntityGetFirstComponentIncludingDisabled(target,"LifetimeComponent") or 0
        local damagemodel_comp = EntityGetFirstComponentIncludingDisabled(target,"DamageModelComponent") or 0
        local camerabound_comp = EntityGetFirstComponentIncludingDisabled(target,"CameraBoundComponent") or 0
        local physics_body_comp = EntityGetFirstComponentIncludingDisabled(target,"PhysicsImageShapeComponent") or 0
        if proj_comp > 0 or lifetime_comp > 0 or camerabound_comp == 0 or damagemodel_comp == 0 or ComponentGetIsEnabled(damagemodel_comp) == false then
            goto skipthistarget
        end

        --Filter by already charmed enemies
        local charm_count = GameGetGameEffectCount(target,"CHARM" )
        if charm_count > 0 then
            goto skipthistarget
        end
        
        --Filter by healer & support-type enemies
        if animal_ai_comp > 0 and ComponentGetValue2(animal_ai_comp,"tries_to_ranged_attack_friends") == true then
            goto skipthistarget
        end

        --Filter by genome
        local genome_comp = EntityGetFirstComponentIncludingDisabled(target,"GenomeDataComponent") or 0
        if HerdIdToString(ComponentGetValue2(genome_comp,"herd_id")) == "player" then
            goto skipthistarget
        end

        --Filter by a suspiciously empty name
        --This means half the enemies in the game can't be possessed because nolla forgot to give them name but it prevents the in-game messages from looking odd
        --Heavily deprioritise targets with no visible name
        local hp_max = ComponentGetValue2(damagemodel_comp,"max_hp")
        if EntityGetName(target) == "" then
            hp_max = hp_max * 0.01
        end

        --At this point we've found a viable target
        --Try to find the highest health target (presumably the strongest) to possess
        if physics_body_comp > 0 then
            hp_max = hp_max * 0.25 --Deprioritise physics body entities for possession since they're a bit tricky to work with
        elseif animal_ai_comp > 0 then
            local has_ranged_attack = ComponentGetValue2(animal_ai_comp,"attack_ranged_enabled") or false
            local has_melee_attack = ComponentGetValue2(animal_ai_comp,"attack_melee_enabled") or false
            if has_melee_attack == false and has_melee_attack == false then
                hp_max = hp_max * 0.15 --Severely Deprioritise enemies with no attacks
            end
        end

        local targ_x, targ_y = EntityGetTransform(target)
        -- if strongest_target.hp ~= nil then
        --     print("comparing " .. tostring(EntityGetName(strongest_target.name) or "nil") .. " with hp " .. tostring(strongest_target.hp or "nil") .. " to " .. EntityGetName(target) .. " with hp " .. tostring(hp_max))
        -- end
        if strongest_target.hp == nil or strongest_target.hp < hp_max then
            strongest_target.id = target
            strongest_target.hp = hp_max
            strongest_target.x = targ_x
            strongest_target.y = targ_y
        end
        ::skipthistarget::
    end

    if strongest_target.id ~= nil then
        local currently_active_felcesis = EntityGetWithTag("felcesis_possessed") or {}
        for _,possessed in ipairs(currently_active_felcesis) do
            EntityKill(possessed)
        end
        return true, strongest_target.id, strongest_target.x, strongest_target.y
    end
    return false
end

return {
    FindPossessionTarget   = FindPossessionTarget,
    CreateMiniboss         = CreateMiniboss,
    CalculateMinibossPower = CalculateMinibossPower
}