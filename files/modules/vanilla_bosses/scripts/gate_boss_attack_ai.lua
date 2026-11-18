function get_magnitude( x, y )
	local result = math.sqrt( x ^ 2 + y ^ 2 )
	return result
end

function moveToGoal(num,ideal_num,change_speed,lower_special)
	if ideal_num - num < 0 then
		if lower_special ~= nil then
			num = math.max(num - lower_special,ideal_num)
		else
			num = math.max(num - change_speed,ideal_num)
		end
	elseif ideal_num - num > 0 then
		num = math.min(num + change_speed,ideal_num)
	end
	local goal_reached = (num == ideal_num)
	return num, goal_reached
end

local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform(entity_id)

local gates = EntityGetInRadiusWithTag(pos_x, pos_y, 500, "gate_monster") or {}
local brothers = {}
for i=1,#gates do local gate = gates[i]
	if gate ~= entity_id and string.sub(EntityGetName(gate),0,20) == "$animal_gate_monster" then
		table.insert(brothers,gate)
	end
end
local brother_count = #brothers
local children = EntityGetAllChildren(entity_id,"monk_hand") or {}
local spell_cards = {}
for i=1,#children do local child = children[i]
	if EntityGetName(child) == "hardmod_gateboss_spell_card" then
		table.insert(spell_cards,child)
	end
end
local card_count = #spell_cards

--This defines all the boss attack speed/amount
local attack_radius = 350
local card_ring_radius = 56
local max_card_count = 6 --How many cards should appear on the ring
local spin_speed_passive = 45 --How fast should the ring spin passively (45 degrees per second)
local spin_speed_direct = 180 --How fast should the ring spin when rapid/can't shoot player (180 degrees per second)
local spin_speed_increment = 135 / 60 --How fast should the ring speed up (135 degrees per 60 frames or a second)
local spin_speed_reduction = 45 / 60 --How fast should the ring slow down (45 degrees per second)
local refill_speed = 30 --Per frame
local fire_speed = 80 --Per frame
local fire_speed_rapid = 30

if brother_count <= 0 then
	max_card_count = 16
	refill_speed = 10
	fire_speed = 30
	fire_speed_rapid = 5
	spin_speed_passive = 90
	spin_speed_direct = 270
	spin_speed_increment = 180 / 30
	spin_speed_reduction = 180 / 60
elseif brother_count <= 1 then
	max_card_count = 12
	refill_speed = 15
	fire_speed = 45
	fire_speed_rapid = 15
	spin_speed_passive = 60
	spin_speed_direct = 200
	spin_speed_increment = 140 / 60
	spin_speed_reduction = 50 / 90
elseif brother_count <= 2 then
	max_card_count = 8
	fire_speed = 60
end

--This is the list of spells the boss can use
dofile_once("mods/noita.hardmod/files/modules/vanilla_bosses/scripts/gate_boss_attack_ai_spells.lua")
local spells = GetSpellAttackListing()



local varcomp = EntityGetFirstComponentIncludingDisabled(entity_id,"VariableStorageComponent")
local extracomp = EntityGetComponentIncludingDisabled(entity_id,"VariableStorageComponent")[2]
local varcomps = EntityGetComponentIncludingDisabled(entity_id,"VariableStorageComponent") or {}
for i=1,#varcomps do local comp = varcomps[i]
	if ComponentGetValue2(comp,"name") == "boss_ai" then
		varcomp = comp
	elseif ComponentGetValue2(comp,"name") == "boss_ai_extra" then
		extracomp = comp
	end
end
if not varcomp then return end

local last_frame = ComponentGetValue2(varcomp,"value_int") --Used to help with timers
local spin_speed = ComponentGetValue2(varcomp,"value_float") --Current card ring spin speed in degrees
local attack_state = ComponentGetValue2(varcomp,"value_string") --Current state ("normal"/"rapid")
local recharged = ComponentGetValue2(varcomp,"value_bool") --Sees if done recharging
local current_max_card_count = ComponentGetValue2(extracomp,"value_int")
local current_spin_angle = ComponentGetValue2(extracomp,"value_float")
local current_frame = GameGetFrameNum()
local spin_state = "passive"
if attack_state == "rapid" then spin_state = "direct" end

if card_count > 0 then
	current_spin_angle = (current_spin_angle + (spin_speed / 60)) % 360
	ComponentSetValue2(extracomp,"value_float",current_spin_angle)
	for i=1,card_count do local spell_card = spell_cards[i]
		local spellcomp = EntityGetFirstComponentIncludingDisabled(spell_card,"VariableStorageComponent")
		local offset = spellcomp and ComponentGetValue2(spellcomp,"value_float") or 0
		local ring_angle = math.rad(current_spin_angle + offset)
		local card_x = pos_x + math.cos(ring_angle) * card_ring_radius
		local card_y = pos_y + math.sin(ring_angle) * card_ring_radius
		EntitySetTransform(spell_card,card_x,card_y)
	end
end

if not recharged then
	if card_count <= 0 then
		SetRandomSeed(current_frame,pos_x + pos_y + entity_id)
		current_max_card_count = max_card_count
		ComponentSetValue2(extracomp,"value_int",current_max_card_count)
		attack_state = "normal"
		if Random(1,4) == 1 then attack_state = "rapid" end --Maybe make rapid rng variable?
		ComponentSetValue2(varcomp,"value_string",attack_state)
	end

	if card_count >= current_max_card_count then
		ComponentSetValue2(varcomp,"value_int",current_frame)
		ComponentSetValue2(varcomp,"value_bool",true)
	elseif card_count < current_max_card_count and current_frame >= last_frame + refill_speed then
		local spell_index = 1
		if attack_state == "rapid" then
			--Ideally should all be the same phasing spell... hmmm...
			--[[
			local phasing_spells = {}
			for i=1,#spells do local phasing = spells[i][3]
				if phasing then
					table.insert(phasing_spells,i)
				end
			end
			spell_index = phasing_spells[Random(1,#phasing_spells)]
			]]--
			spell_index = 1
		else
			spell_index = Random(1,#spells)
		end
		local offset = (360 / current_max_card_count) * (card_count + 1)
		local ring_angle = math.rad(current_spin_angle + offset)
		local card_x = pos_x + math.cos(ring_angle) * card_ring_radius
		local card_y = pos_y + math.sin(ring_angle) * card_ring_radius
		local spell_card = EntityLoad("mods/noita.hardmod/files/modules/vanilla_bosses/entity/gate_boss_spell_card_visual.xml",card_x,card_y)

		local iconcomp = EntityGetFirstComponentIncludingDisabled(spell_card,"SpriteComponent")
		local icon_path = "data/ui_gfx/gun_actions/" .. spells[spell_index][1] .. ".png"
		if iconcomp then
			ComponentSetValue2(iconcomp,"image_file",icon_path)
			if spells[spell_index][4] == "static" then --If static projectile then change border
				local bordercomp = EntityGetComponentIncludingDisabled(spell_card,"SpriteComponent")[2]
				ComponentSetValue2(bordercomp,"image_file","data/ui_gfx/inventory/item_bg_static_projectile.png")
			end
			EntityRefreshSprite(spell_card,iconcomp)
		end

		local spellcomp = EntityGetFirstComponentIncludingDisabled(spell_card,"VariableStorageComponent")
		if spellcomp then
			ComponentSetValue2(spellcomp,"value_int",spell_index)
			ComponentSetValue2(spellcomp,"value_float",offset)
		end

		if attack_state == "rapid" then --Visual trail to the card if in rapid mode
			local bordercomp = EntityGetComponentIncludingDisabled(spell_card,"SpriteComponent")[2]
			local border = ComponentGetValue2(bordercomp,"image_file")
			local fxcomp = EntityAddComponent2(spell_card, "SpriteParticleEmitterComponent", {
				sprite_file=border,
				delay=0,
				lifetime=0.75,
				sprite_centered=true,
				render_back=true,
				velocity_slowdown=0,
				rotation=0,
				angular_velocity=0,
				use_rotation_from_entity=true,
				use_velocity_as_rotation=false,
				additive=true,
				emissive=false,
				emission_interval_min_frames=6,
				emission_interval_max_frames=6,
				count_min=1,
				count_max=1,
			})
			ComponentSetValue2(fxcomp,"color",1,1,1,0.75)
			ComponentSetValue2(fxcomp,"color_change",0,0,0,-3)
			ComponentSetValue2(fxcomp,"velocity",0,0)
			ComponentSetValue2(fxcomp,"gravity",0,0)
			ComponentSetValue2(fxcomp,"scale",1,1)
			ComponentSetValue2(fxcomp,"scale_velocity",0,0)
		end
		EntityAddChild(entity_id,spell_card)
		ComponentSetValue2(varcomp,"value_int",current_frame)
	end
elseif attack_state == "normal" then
	if card_count <= 0 then
		ComponentSetValue2(varcomp,"value_bool",false)
	elseif current_frame >= last_frame + fire_speed then
		local player_id = EntityGetInRadiusWithTag(pos_x,pos_y,attack_radius,"player_unit") or EntityGetInRadiusWithTag(pos_x,pos_y,attack_radius,"polymorphed_player")
		if player_id == nil or not EntityGetIsAlive(player_id[1]) then return end
		player_id = player_id[1]
		local p_x, p_y = EntityGetTransform(player_id)

		local closest_distance = attack_radius + 1
		local attack_card = nil
		for i=1,card_count do local spell_card = spell_cards[i]
			local card_x, card_y = EntityGetTransform(spell_card)
			local distance = get_magnitude( (card_x - p_x), (card_y - p_y) )
			if distance < closest_distance and (not RaytracePlatforms(card_x,card_y,p_x,p_y)) then
				closest_distance = distance
				attack_card = spell_card
			end
		end
		if attack_card ~= nil then
			local card_x, card_y = EntityGetTransform(attack_card)
			local spellcomp = EntityGetFirstComponentIncludingDisabled(attack_card,"VariableStorageComponent")
			local spell_index = spellcomp and ComponentGetValue2(spellcomp,"value_int") or 1
			local spell_stats = spells[spell_index]
			local spell_name = spell_stats[1]
			local speed_min = spell_stats[2][1]
			local speed_max = spell_stats[2][2]
			local fire_angle = math.atan2(p_y - card_y,p_x - card_x)
			local length = Random(speed_min,speed_max)
			local vel_x = math.cos(fire_angle) * length
			local vel_y = math.sin(fire_angle) * length

			local pid = EntityLoad("mods/noita.hardmod/files/modules/vanilla_bosses/entity/gate_boss_projectiles/" .. spell_name .. ".xml", card_x, card_y)
			GameShootProjectile(entity_id, card_x, card_y, card_x + vel_x, card_y + vel_y,pid)
			local projcomp = EntityGetFirstComponentIncludingDisabled( pid, "ProjectileComponent" )
			if projcomp then
				ComponentSetValue2(projcomp, "mWhoShot", entity_id)
				local genomecomp = EntityGetFirstComponentIncludingDisabled( entity_id, "GenomeDataComponent" )
				if genomecomp then
					ComponentSetValue2(projcomp, "mShooterHerdId", ComponentGetValue2(genomecomp,"herd_id"))
				end
			end

			local velcomp = EntityGetFirstComponentIncludingDisabled( pid, "VelocityComponent" )
			if velcomp then
				ComponentSetValue2(velcomp, "mVelocity", vel_x, vel_y)
			end

			EntityKill(attack_card)
			ComponentSetValue2(varcomp,"value_int",current_frame)
		else
			spin_state = "direct"
		end
	end
elseif attack_state == "rapid" then
	if card_count <= 0 then
		ComponentSetValue2(varcomp,"value_bool",false)
	elseif current_frame >= last_frame + fire_speed_rapid then
		local player_id = EntityGetInRadiusWithTag(pos_x,pos_y,attack_radius,"player_unit") or EntityGetInRadiusWithTag(pos_x,pos_y,attack_radius,"polymorphed_player")
		if player_id == nil or not EntityGetIsAlive(player_id[1]) then return end
		player_id = player_id[1]
		local p_x, p_y = EntityGetTransform(player_id)

		local closest_distance = attack_radius + 1
		local attack_card = nil
		for i=1,card_count do local spell_card = spell_cards[i]
			local card_x, card_y = EntityGetTransform(spell_card)
			local distance = get_magnitude( (card_x - p_x), (card_y - p_y) )
			if distance < closest_distance then
				closest_distance = distance
				attack_card = spell_card
			end
		end
		if attack_card ~= nil then
			local card_x, card_y = EntityGetTransform(attack_card)
			local spellcomp = EntityGetFirstComponentIncludingDisabled(attack_card,"VariableStorageComponent")
			local spell_index = spellcomp and ComponentGetValue2(spellcomp,"value_int") or 1
			local spell_stats = spells[spell_index]
			local spell_name = spell_stats[1]
			local speed_min = spell_stats[2][1]
			local speed_max = spell_stats[2][2]
			local fire_angle = math.atan2(p_y - card_y,p_x - card_x)
			local length = Random(speed_min,speed_max)
			local vel_x = math.cos(fire_angle) * length
			local vel_y = math.sin(fire_angle) * length

			local pid = EntityLoad("mods/noita.hardmod/files/modules/vanilla_bosses/entity/gate_boss_projectiles/" .. spell_name .. ".xml", card_x, card_y)
			GameShootProjectile(entity_id, card_x, card_y, card_x + vel_x, card_y + vel_y,pid)

			local projcomp = EntityGetFirstComponentIncludingDisabled( pid, "ProjectileComponent" )
			if projcomp then
				ComponentSetValue2(projcomp, "mWhoShot", entity_id)
				local genomecomp = EntityGetFirstComponentIncludingDisabled( entity_id, "GenomeDataComponent" )
				if genomecomp then
					ComponentSetValue2(projcomp, "mShooterHerdId", ComponentGetValue2(genomecomp,"herd_id"))
				end
			end

			local velcomp = EntityGetFirstComponentIncludingDisabled( pid, "VelocityComponent" )
			if velcomp then
				ComponentSetValue2(velcomp, "mVelocity", vel_x, vel_y)
			end

			EntityKill(attack_card)
		end
		ComponentSetValue2(varcomp,"value_int",current_frame)
	end
else
	ComponentSetValue2(varcomp,"value_bool",false)
end

if spin_state == "passive" and spin_speed ~= spin_speed_passive then
	spin_speed = moveToGoal(spin_speed,spin_speed_passive,spin_speed_increment,spin_speed_reduction)
	ComponentSetValue2(varcomp,"value_float",spin_speed)
elseif spin_state == "direct" and spin_speed ~= spin_speed_direct then
	spin_speed = moveToGoal(spin_speed,spin_speed_direct,spin_speed_increment)
	ComponentSetValue2(varcomp,"value_float",spin_speed)
end
