local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local eperk_utils ---@type eperk_utils

local biomes = dofile_once("mods/noita.hardmod/lib/biome_index.lua")

---@class enemy_perk
---@field id string string ID
---@field name string? string name (viewable in progress)
---@field description string? description of the perk (viewable in progress)
---@field sprite string? path to the perk's sprite
---@field icon string? path to the perk's icon
---@field not_progress boolean? if true, perk won't show up in progress menu
---@field weight number? probability of the perk being pulled, default 10
---@field biome_conditions table? custom condition functions that run if the target_enemy is in the keyed biome, if value is a number it will set the perk weight to that value
---@field priority number? priority for the order its shown above enemies' heads or in the inspect window, default 10
---@field max integer? max number of this perk an enemy can have
---@field condition function? if added, this function must return true, is passed the `data` table
---@field func function? function that actually does the stuff, is passed the `data` table
---@field func_handler function? function that runs on the perk handler every 80f, is passed sprite components of in-world perk icons
---@field func_inspector function? function that runs every frame in the eperk inspector, is passed a table of all the perks held by the enemy
---@field post_func function? function that runs after all perks have been applied

local dir = "mods/noita.hardmod/files/modules/enemy_perks/"
local sprites_path = "mods/noita.hardmod/files/modules/enemy_perks/perk_sprites/"
local icons_path = "mods/noita.hardmod/files/modules/enemy_perks/perk_icons/"

local enemy_is_ranged_attack = function(self, data)
	local animal_ai_comp = EntityGetFirstComponentIncludingDisabled(data.target_enemy,"AnimalAIComponent")
	if animal_ai_comp
	and ComponentGetValue2(animal_ai_comp,"attack_ranged_enabled")
	and not ComponentGetValue2(animal_ai_comp, "tries_to_ranged_attack_friends") then
		return true
	end
end

local enemy_is_melee = function(self, data)
	local animal_ai_comp = EntityGetFirstComponentIncludingDisabled(data.target_enemy,"AnimalAIComponent")
	if animal_ai_comp and ComponentGetValue2(animal_ai_comp,"attack_melee_enabled") then
		return true
	end
end

-- dont give a blood perk if already has blood perk, is a boss, or is swapper mage
local blood_perk_check = function(self, data)
	if data.dmc then
		if ComponentGetValue2(data.dmc, "blood_material") == self.blood_material then return end
		return not (data.is_boss or EntityGetName(data.target_enemy) == "$animal_wizard_swapper")
	end
end

local function increment_weight_with_level(self, data, multiplier)
	multiplier = multiplier or 0.5
	self.weight = self.weight + data.level*multiplier
	return true
end

local function is_projectile_immune(self, data)
	return not (data.dmc and ComponentObjectGetValue2(data.dmc, "damage_multipliers", "projectile") > 0
		and GameGetGameEffectCount(data.target_enemy, "PROTECTION_PROJECTILE") == 0)
end

local function spawn_on_death_blacklist(self, data)
	local banned_creatures = {
		["data/entities/animals/wizard_swapper.xml"] = true,
		["data/entities/animals/rat.xml"] = true,
		["data/entities/animals/skullrat.xml"] = true,
		["data/entities/animals/crypt/skullrat.xml"] = true,
		["data/entities/animals/skullfly.xml"] = true,
		["data/entities/animals/crypt/skullfly.xml"] = true,
	}
	local banned_perks = {
		"HARDMOD_FORBIDDEN_ARTS"
	}
	for _,banned_perk in ipairs(banned_perks) do
		if data.how_many_of_each_perk[banned_perk] then return end
	end

	return not (banned_creatures[EntityGetFilename(data.target_enemy)] or data.how_many_of_each_perk["HARDMOD_BOUNTY"] or data.how_many_of_each_perk["HARDMOD_SHADOW_REVIVAL"])
end

local function split_string(inputstr, sep)
	sep = sep or "%s"
	local t= {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, str)
	end
	return t
end

-- The `data` table provides `target_enemy` (eid), `already_held_perks` (perk_id[]), `player` (eid) and `player_poly_identity` (table)

local ideal_form_perk = {
	id = "IDEAL_FORM",
	name = "$hardmod_eperk_ideal_form_name",
	description = "$hardmod_eperk_ideal_form_desc",
	weight = 1,
	priority = -20,
	condition = function(self, data)
		return data.is_polymorphed and not EntityHasTag(data.target_enemy, "polymorphed_player")
	end,
	func = function(self, entity_id, data)
		local polymorph_statuses = {
			["POLYMORPH"] = true,
			["POLYMORPH_RANDOM"] = true,
			["POLYMORPH_UNSTABLE"] = true,
			["POLYMORPH_CESSATION"] = true,
		}
		for _,child in ipairs(EntityGetAllChildren(entity_id) or {}) do
			local child_has_poly_comp
			for _,game_effect_comp in ipairs(EntityGetComponentIncludingDisabled(child, "GameEffectComponent") or {}) do
				if polymorph_statuses[ComponentGetValue2(game_effect_comp, "effect")] then
					ComponentSetValue2(game_effect_comp, "frames", 0)
					child_has_poly_comp = true
				end
			end
			if child_has_poly_comp then
				for _,lifetime_comp in ipairs(EntityGetComponent(child, "LifetimeComponent") or {}) do
					EntityRemoveComponent(child, lifetime_comp)
				end
			end
		end
	end,
	on_death = function(self, entity_id, ddata)
		ModSettingSet("hardmod.ideal_form_kills", (ModSettingGet("hardmod.ideal_form_kills") or 0) + 1)
		if utils.MatchDateLocal({month = 3, day = 31}) then
			ModSettingSet("hardmod.ideal_form_kills_bonus", (ModSettingGet("hardmod.ideal_form_kills_bonus") or 0) + 1)
		end
	end --track sins
}
if utils.MatchDateLocal({month = 3, day = 31}) then
	ideal_form_perk.weight = 2
	ideal_form_perk.sprite = dir.."perk_sprites/ideal_form_t.png"
	ideal_form_perk.icon = dir.."perk_icons/ideal_form_t.png"
end

---@type enemy_perk[]
local enemy_perks = {}
enemy_perks = {
	--[[
	{
		id = "TEST_PERK",
		name = "$hardmod_enemy_perks_test",
		description = "Wow, what a great test perk!",
		weight = 10,
		condition = function(self, data) end,
		func = function(self, holder, perk_entity)
			GetGameEffectLoadTo(holder, "REGENERATION", true)
		end
	},--]]
	{
		id = "EXTRA_HP",
		name = "$hardmod_eperk_extra_hp_name",
		description = "$hardmod_eperk_extra_hp_desc",
		weight = 10,
		condition = function(self, data) return data.dmc end,
		func = function(self, entity_id, data)
			ComponentSetValue2(data.dmc, "max_hp", ComponentGetValue2(data.dmc, "max_hp") * 1.5)
			ComponentSetValue2(data.dmc, "hp", ComponentGetValue2(data.dmc, "hp") * 1.5)
		end
	},
	{
		id = "RECYCLE_HEALTH",
		name = "$hardmod_eperk_recycle_health_name",
		description = "$hardmod_eperk_recycle_health_desc",
		weight = 6,
		priority = 6,
		max = 0, --this perk is a wasted entry as is, rework to be stronger (ie grant Max HP in addition to HP)
		func = function(self, entity_id, data)
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_damage_received = dir.."scripts/recycle_health.lua",
			})
		end
	},
	{
		id = "LEECH",
		name = "$hardmod_eperk_leech_name",
		description = "$hardmod_eperk_leech_desc",
		weight = 3,
		priority = 6,
		min_level = 1,
		max = 1,
		unique_slot = "large_aura",
		condition = function(self, data) return data.dmc and ComponentGetValue2(data.dmc, "hp") >= 8 end, --only grant perk if >200 hp
		func = function(self, entity_id, data)
			EntityAddChild(data.handler, EntityLoad(dir.."entities/leech.xml", data.x, data.y))
		end
	},
	{
		id = "PROTECTOR",
		name = "$hardmod_eperk_protector_name",
		description = "$hardmod_eperk_protector_desc",
		weight = 8,
		max = 2,
		unique_slot = "small_aura",
		biome_conditions = {
			mines = 4,
			coal_pits = 4,
			snowy_depths = 6,
		},
		condition = function(self, data)
			if not data.dmc then return end
			if data.how_many_of_each_perk["HARDMOD_AREA_PROTECTOR"] then return end
			local max_hp = ComponentGetValue2(data.dmc, "max_hp")
			return max_hp >= 2
		end,
		func = function(self, entity_id, data)
			local x, y = EntityGetTransform(entity_id)
			local tier = ( data.how_many_of_each_perk[self.id] or 0 ) + 1

			EntityAddChild(entity_id, EntityLoad( dir.."entities/protector_shield_t"..tier..".xml", x, y))
		end
	},
	{
		id = "AREA_PROTECTOR",
		name = "$hardmod_eperk_area_protector_name",
		description = "$hardmod_eperk_area_protector_desc",
		weight = 1,
		max = 2,
		min_level = 3,
		-- unique_slot = "large_aura", -- has great synergy with other large_aura perks so I think we should keep it separate
		biome_conditions = {
			magical_temple = 2,
			temple_of_the_art = 3,
			wizards_den = 4,
		},
		condition = function(self, data)
			if data.how_many_of_each_perk["HARDMOD_PROTECTOR"] then return end
			return data.dmc ~= nil
		end,
		func = function(self, entity_id, data)
			local x, y = EntityGetTransform(entity_id)
			local tier = ( data.how_many_of_each_perk[self.id] or 0 ) + 1

			if tier == 1 then
				EntityAddChild(entity_id, EntityLoad( dir.."entities/area_protector_shield_t1.xml", x, y))
			elseif tier == 2 then
				EntityAddChild(entity_id, EntityLoad( dir.."entities/area_protector_shield_t2.xml", x, y))
			end
		end
	},
	{
		id = "DRY_SPELL",
		name = "$hardmod_eperk_dry_spell_name",
		description = "$hardmod_eperk_dry_spell_desc",
		weight = 5,
		max = 1,
		unique_slot = "small_aura",
		biome_conditions = {
			sandcave = 10,
			hell = 10,
		},
		func = function(self, entity_id, data)
			local x, y = EntityGetTransform(entity_id)
			EntityAddChild(entity_id, EntityLoad(dir.."entities/dry_spell.xml", x, y))
		end
	},
	{
		id = "SHADOW_REVIVAL",
		name = "$hardmod_eperk_shadow_revival_name",
		description = "$hardmod_eperk_shadow_revival_desc",
		weight = 4,
		priority = 4,
		max = 1,
		min_level = 5,
		unique_slot = "on_death",
		condition = function(self, data) return data.dmc and not data.is_boss end,
		func = function(self, entity_id, data)
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_death = "mods/noita.hardmod/files/modules/enemy_perks/scripts/spawn_shadow_revive_orb.lua",
			})
			EntityAddComponent2(entity_id, "VariableStorageComponent", {_tags = "no_gold_drop"})

			ComponentSetValue2(data.dmc, "ragdoll_fx_forced", "DISINTEGRATED")
		end
	},
	{
		id = "QUANTUM_CLONES",
		name = "$hardmod_eperk_quantum_clones_name",
		description = "$hardmod_eperk_quantum_clones_desc",
		weight = 1,
		max = 5,
		min_level = 4,
		biome_conditions = {
			magical_temple = 3,
			wizards_den = 3,
		},
		condition = function(self, data)
			return not (data.is_boss or data.is_polymorphed)
		end,
		clone_colours = {
			{255,0,0, "spark_red"}, --Red
			{0,0,255, "spark_blue"}, --Blue
			{255,255,0, "spark_yellow"}, --Yellow
			{255,0,255, "spark_purple"}, --Magenta
			{0,255,255, "spark_teal"}, --Cyan
			{0,255,0, "spark_green"}, --Green
		},
		post_func = function(self, entity_id, data)
			if data.has_cloned then return end
			data.has_cloned = true

			local gang = {entity_id}
			local clones_to_make = data.how_many_of_each_perk[self.id]
			for i = 1, clones_to_make do
				local clone = EntityLoad(EntityGetFilename(entity_id), data.x, data.y)
				EntityAddTag(clone, "hardmod_blessed")
				for _,cbc in ipairs(EntityGetComponentIncludingDisabled(clone, "CameraBoundComponent") or {}) do
					EntityRemoveComponent(clone, cbc)
				end
				---@diagnostic disable-next-line: param-type-mismatch
				eperk_utils.give_enemy_perks(clone, utils.deepcopy(data.selected_perks), data)
				gang[#gang+1] = clone
			end

			for i,member in ipairs(gang) do
				local child = EntityCreateNew("hardmod.eperk_enemy_clone_data")
				EntityAddChild(member, child)
				local colour_table = self.clone_colours[i]
				if not colour_table then colour_table = {
					(1-Random()^2)*255,
					(1-Random()^2)*255,
					(1-Random()^2)*255,
				} end --if outside of colour table, pick random colours

				EntityAddComponent2(child, "InheritTransformComponent")

				EntityAddComponent2(child, "LightComponent", {
					r = colour_table[1],
					g = colour_table[2],
					b = colour_table[3],
					radius = 24,
				})
				EntityAddComponent2(child, "SpriteComponent", {
					image_file = dir.."gfx/quantum_fx.xml",
					z_index = 0.9
				})
				EntityAddComponent2(child, "PotionComponent", {
					custom_color_material = CellFactory_GetType(colour_table[4])
				})

				EntityAddComponent2(child, "LuaComponent", {
					script_source_file = dir.."scripts/check_quantum_clones_dead.lua",
					script_death = dir.."scripts/check_quantum_clones_dead.lua",
					execute_every_n_frame = 120,
					limit_how_many_times_per_frame = entity_id,
					limit_to_every_n_frame = #gang
				})

				EntityAddComponent2(child, "VariableStorageComponent", {
					name = "hardmod_quantum_clones_data",
					value_int = entity_id
				})
			end
		end,
	},
	{
		id = "PYRELORD",
		name = "$hardmod_eperk_pyrelord_name",
		description = "$hardmod_eperk_pyrelord_desc",
		weight = 8,
		max = 2,
		biome_conditions = {
			snowy_depths = 1,
			frozen_vault = 1,
			sandcave = 10,
			hell = 10,
		},
		condition = enemy_is_ranged_attack,
		func = function(self, entity_id, data)
			GetGameEffectLoadTo(entity_id, "PROTECTION_FIRE", false)
			
			local stacks = (data.how_many_of_each_perk[self.id] or 0) + 1
			if stacks == 1 then
				EntityAddComponent2(entity_id, "LuaComponent", {
					script_shot = dir.."scripts/pyrelord_on_shot.lua",
					execute_every_n_frame = -1,
				})
			elseif stacks == 2 then
				EntityAddComponent2(entity_id, "LuaComponent", {
					script_shot = dir.."scripts/pyrelord_plus_on_shot.lua",
					execute_every_n_frame = -1,
				})
			end
		end
	},
	{
		id = "THUNDERLORD",
		name = "$hardmod_eperk_thunderlord_name",
		description = "$hardmod_eperk_thunderlord_desc",
		weight = 4,
		priority = 7,
		max = 1,
		biome_conditions = {
			sky = 8,
		},
		condition = function(self, data)
			if EntityHasTag(data.target_enemy, "thundermage") then return end
			local animal_ai_comp = EntityGetFirstComponentIncludingDisabled(data.target_enemy,"AnimalAIComponent")
			if animal_ai_comp
			and ComponentGetValue2(animal_ai_comp,"attack_ranged_enabled")
			and not ComponentGetValue2(animal_ai_comp, "tries_to_ranged_attack_friends")
			and ComponentGetValue2(animal_ai_comp, "attack_ranged_frames_between") >= 60 then -- only on slow shooters
				return true
			end
		end,
		func = function(self, entity_id, data)
			if not is_projectile_immune(self, data) then GetGameEffectLoadTo(entity_id, "PROTECTION_ELECTRICITY", false) else print("not eimmune :)") end
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_shot = dir.."scripts/thunderlord_on_shot.lua",
				execute_every_n_frame = -1,
			})
		end
	},
	{
		id = "AEROLORD",
		name = "$hardmod_eperk_aerolord_name",
		description = "$hardmod_eperk_aerolord_desc",
		weight = 1,
		max = 1,
		biome_conditions = {
			sky = 2,
		},
		condition = enemy_is_ranged_attack,
		func = function(self, entity_id, data)
			GetGameEffectLoadTo(entity_id, "KNOCKBACK_IMMUNITY", false)
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_shot = dir.."scripts/aerolord_on_shot.lua",
				execute_every_n_frame = -1,
			})
		end
	},
	{
		id = "DARK_FLAMES",
		name = "$hardmod_eperk_dark_flames_name",
		description = "$hardmod_eperk_dark_flames_desc",
		weight = 2,
		max = 1,
		biome_conditions = {
			magical_temple = 4,
			temple_of_the_art = 8,
			wizards_den = 8,
		},
		condition = function(self, data)
			local animal_ai_comp = EntityGetFirstComponentIncludingDisabled(data.target_enemy,"AnimalAIComponent")
			if animal_ai_comp
			and ComponentGetValue2(animal_ai_comp,"attack_ranged_enabled")
			and not ComponentGetValue2(animal_ai_comp, "tries_to_ranged_attack_friends")
			and ComponentGetValue2(animal_ai_comp, "attack_ranged_frames_between") >= 60 then -- only on slow shooters
				return true
			end
		end,
		func = function(self, entity_id, data)
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_shot = dir.."scripts/dark_flames_on_shot.lua",
				execute_every_n_frame = -1,
			})
		end
	},
	{
		id = "CURSER",
		name = "$hardmod_eperk_curser_name",
		description = "$hardmod_eperk_curser_desc",
		weight = 3,
		priority = 7,
		max = 1,
		condition = enemy_is_ranged_attack,
		func = function(self, entity_id, data)
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_shot = dir.."generated/curser_shot.lua",
				execute_every_n_frame = -1,
			})
		end
	},
	--{
	--	id = "BLINDING_CURSER",
	--	name = "$hardmod_eperk_blinding_curser_name",
	--	description = "$hardmod_eperk_blinding_curser_desc",
	--	weight = 4,
	--	priority = 9,
	--	max = 1,
	--	condition = function(self, data) return data.level > 5 and enemy_is_ranged_attack(self, data) end,
	--	func = function(self, entity_id, data)
	--		EntityAddComponent2(entity_id, "LuaComponent", {
	--			script_shot = dir.."scripts/blinding_curser_shot.lua",
	--			execute_every_n_frame = -1,
	--		})
	--	end
	--},
	{
		id = "DAMAGE_BUFFER",
		name = "$hardmod_eperk_damage_buffer_name",
		description = "$hardmod_eperk_damage_buffer_desc",
		weight = 6,
		priority = 3,
		max = 1,
		min_level = 3,
		unique_slot = "large_aura",
		func = function(self, entity_id, data)
			EntityAddChild(entity_id, EntityLoad(dir.."entities/damage_buffer.xml", data.x, data.y))
		end
	},
	{
		id = "WET_AURA",
		name = "$hardmod_eperk_wet_aura_name",
		description = "$hardmod_eperk_wet_aura_desc",
		weight = 6,
		priority = 0,
		max = 1,
		unique_slot = "large_aura",
		condition = function(self, data)
			return not (data.dmc and ComponentGetValue2(data.dmc, "wet_status_effect_damage") > 0)
		end,
		func = function(self, entity_id, data)
			EntityAddChild(entity_id, EntityLoad(dir.."entities/wet_aura.xml", data.x, data.y))
		end
	},
	{
		id = "STINKY_AURA",
		name = "$hardmod_eperk_stinky_aura_name",
		description = "$hardmod_eperk_stinky_aura_desc",
		weight = 2,
		priority = 0,
		max = 1,
		unique_slot = "large_aura",
		conditions = function(self, data)
			return data.dmc and string.find("blood,slime,sludge", ComponentGetValue2(data.dmc, "blood_material"))
		end,
		func = function(self, entity_id, data)
			GetGameEffectLoadTo(entity_id, "PROTECTION_RADIOACTIVITY", false)
			EntityAddChild(entity_id, EntityLoad(dir.."entities/stinky_aura.xml", data.x, data.y))
		end
	},
	{
		id = "ELECTRICITY",
		name = "$perk_electricity",
		description = "$hardmod_eperk_electricity_desc",
		weight = 5,
		biome_conditions = {
			fungal_caverns = 2,
			vault = 2,
			frozen_vault = 2,
			powerplant = 8,
		},
		max = 1,
		condition = function(self, data)
			return not (EntityHasTag(data.target_enemy, "thundermage") or is_projectile_immune(self, data))
		end,
		func = function(self, entity_id, data)
			GetGameEffectLoadTo(entity_id, "PROTECTION_ELECTRICITY", false)
			local child_id = EntityLoad("data/entities/misc/perks/electricity.xml", data.x, data.y)
			local elec_comp = EntityGetFirstComponent(child_id, "ElectricitySourceComponent")
			if elec_comp then ComponentSetValue2(elec_comp, "emission_interval_frames", 48) end
			EntityAddTag(child_id, "perk_entity")
			EntityAddChild(entity_id, child_id)
		end
	},
	{
		id = "MAGIC_RESISTANCE",
		name = "$hardmod_eperk_magic_resistance_name",
		description = "$hardmod_eperk_magic_resistance_desc",
		weight = 6,
		biome_conditions = {
			magical_temple = 10,
			temple_of_the_art = 10,
			wizards_den = 10,
		},
		condition = function(...) return not is_projectile_immune(...) end,
		func = function(self, entity_id, data)
			ComponentObjectSetValue2(data.dmc, "damage_multipliers", "projectile",
				ComponentObjectGetValue2(data.dmc, "damage_multipliers", "projectile") * .5
			)
		end
	},
	{
		id = "EXPLOSION_IMMUNITY",
		name = "$perk_protection_explosion",
		description = "$hardmod_eperk_explosion_immunity_desc",
		weight = 5,
		priority = 3,
		max = 1,
		condition = function(self, data)
			increment_weight_with_level(self, data)
			return GameGetGameEffectCount(data.target_enemy, "PROTECTION_EXPLOSION") == 0 and not is_projectile_immune(self, data) end,
		func = function(self, entity_id, data)
			GetGameEffectLoadTo(entity_id, "PROTECTION_EXPLOSION", false)
		end
	},
	{
		id = "FREEZE_IMMUNITY",
		name = "$hardmod_eperk_freeze_immunity_name",
		description = "$hardmod_eperk_freeze_immunity_desc",
		weight = 3,
		priority = 3,
		max = 1,
		min_level = 3,
		biome_conditions = {
			frozen_vault = 6,
			sandcave = 6,
			hell = 6,
		},
		condition = function(self, data)
			increment_weight_with_level(self, data)
			return GameGetGameEffectCount(data.target_enemy, "PROTECTION_FREEZE") == 0 and not is_projectile_immune(self, data)
		end,
		func = function(self, entity_id, data)
			GetGameEffectLoadTo(entity_id, "PROTECTION_FREEZE", false)
		end
	},
	{
		id = "POLYMORPH_IMMUNITY",
		name = "$hardmod_eperk_polymorph_immunity_name",
		description = "$hardmod_eperk_polymorph_immunity_desc",
		weight = 5,
		priority = 3,
		max = 1,
		biome_conditions = {
			ancient_lab = 10,
		},
		condition = function(self, data)
			increment_weight_with_level(self, data)
			return GameGetGameEffectCount(data.target_enemy, "PROTECTION_POLYMORPH") == 0
				and not (EntityHasTag(data.target_enemy, "polymorphable_NOT") or data.is_polymorphed or data.boss)
		end,
		func = function(self, entity_id, data)
			GetGameEffectLoadTo(entity_id, "PROTECTION_POLYMORPH", false)
		end,
	},
	{
		id = "MORE_BLOOD",
		name = "$perk_global_gore",
		description = "$hardmod_eperk_more_blood_desc",
		weight = 3,
		priority = 4,
		max = 3,
		biome_conditions = {
			meat_realm = 8,
		},
		condition = function(self, data)
			if data.unique_slots.blood then self.weight = 8 end
			return data.dmc
		end,
		func = function(self, entity_id, data)
			if ComponentGetValue2(data.dmc, "blood_material") == "blood_fading" then ComponentSetValue2(data.dmc, "blood_material", "blood") end
			ComponentSetValue2(data.dmc, "blood_multiplier", ComponentGetValue2(data.dmc, "blood_multiplier") * 3)
		end
	},
	{
		id = "COLD_BLOOD",
		name = "$hardmod_eperk_cold_blood_name",
		description = "$hardmod_eperk_cold_blood_desc",
		weight = 3,
		priority = 4,
		max = 1,
		unique_slot = "blood",
		blood_material = "blood_cold",
		biome_conditions = {
			snowy_depths = 6,
			frozen_vault = 6,
		},
		condition = blood_perk_check,
		func = function(self, entity_id, data)
			ComponentSetValue2(data.dmc, "blood_material", "blood_cold")
			ComponentSetValue2(data.dmc, "blood_spray_material", "blood_cold")
			EntitySetDamageFromMaterial(entity_id, "blood_cold", 0)
			EntitySetDamageFromMaterial(entity_id, "blood_cold_vapour", 0)
			ComponentSetValue2(data.dmc, "blood_multiplier", ComponentGetValue2(data.dmc, "blood_multiplier") * 1.5)
			ComponentSetValue2(data.dmc, "blood_multiplier", ComponentGetValue2(data.dmc, "blood_multiplier") * 1.5)
		end
	},
	{
		id = "LAVA_BLOOD",
		name = "$hardmod_eperk_lava_blood_name",
		description = "$hardmod_eperk_lava_blood_desc",
		weight = 3,
		priority = 5,
		max = 1,
		unique_slot = "blood",
		blood_material = "lava",
		condition = blood_perk_check,
		func = function(self, entity_id, data)
			ComponentSetValue2(data.dmc, "blood_material", "lava")
			ComponentSetValue2(data.dmc, "blood_spray_material", "lava")
			ComponentSetValue2(data.dmc, "blood_multiplier", ComponentGetValue2(data.dmc, "blood_multiplier") * 1.5)
			ComponentSetValue2(data.dmc, "wet_status_effect_damage", 0.1)
			EntitySetDamageFromMaterial(entity_id, "water", 0.0002)
			EntitySetDamageFromMaterial(entity_id, "mud", 0.0002)
			EntitySetDamageFromMaterial(entity_id, "water_swamp", 0.0002)
			EntitySetDamageFromMaterial(entity_id, "water_salt", 0.0002)
			EntitySetDamageFromMaterial(entity_id, "swamp", 0.0002)
			EntitySetDamageFromMaterial(entity_id, "snow", 0.0002)
			EntitySetDamageFromMaterial(entity_id, "water_ice", 0.0002)

			EntitySetDamageFromMaterial(entity_id, "lava", 0)
			GetGameEffectLoadTo(entity_id, "PROTECTION_FIRE", false)
		end
	},
	{
		id = "POISON_BLOOD",
		name = "$hardmod_eperk_poison_blood_name",
		description = "$hardmod_eperk_poison_blood_desc",
		weight = 3,
		priority = 5,
		max = 1,
		unique_slot = "blood",
		blood_material = "poison",
		condition = blood_perk_check,
		func = function(self, entity_id, data)
			ComponentSetValue2(data.dmc, "blood_material", "poison")
			ComponentSetValue2(data.dmc, "blood_spray_material", "poison")
			EntitySetDamageFromMaterial(entity_id, "poison", 0)
			ComponentObjectSetValue2(data.dmc, "damage_multipliers", "poison", 0)
			ComponentSetValue2(data.dmc, "blood_multiplier", ComponentGetValue2(data.dmc, "blood_multiplier") * 1.5)
		end
	},
	{
		id = "TELEPORT_BLOOD",
		name = "$hardmod_eperk_teleport_blood_name",
		description = "$hardmod_eperk_teleport_blood_desc",
		weight = 3,
		max = 1,
		min_level = 3,
		unique_slot = "blood",
		blood_material = "magic_liquid_teleportation",
		condition = blood_perk_check,
		func = function(self, entity_id, data)
			ComponentSetValue2(data.dmc, "blood_material", "magic_liquid_teleportation")
			ComponentSetValue2(data.dmc, "blood_spray_material", "magic_liquid_teleportation")
			ComponentSetValue2(data.dmc, "blood_multiplier", ComponentGetValue2(data.dmc, "blood_multiplier") * 1.5)

			local eid = EntityCreateNew("random_teleports")
			EntityAddComponent2(eid, "GameEffectComponent", {
				effect = "TELEPORTATION",
				frames = -1,
				teleportation_probability = 50,
				teleportation_delay_min_frames = 600,
				teleportation_radius_max = 324,
			})
			EntityAddChild(entity_id, eid)
		end
	},
	{
		id = "POLYMORPH_BLOOD",
		name = "$hardmod_eperk_polymorph_blood_name",
		description = "$hardmod_eperk_polymorph_blood_desc",
		weight = .1,
		priority = 15,
		max = 1,
		min_level = 6,
		unique_slot = "blood",
		blood_material = "magic_liquid_polymorph",
		biome_conditions = {
			ancient_lab = 1,
		},
		condition = blood_perk_check,
		func = function(self, entity_id, data)
			GetGameEffectLoadTo(entity_id, "PROTECTION_POLYMORPH", false)

			local blood_material
			if HerdIdToString(utils.GetHerdID(entity_id)) == "orcs" then
				blood_material = "magic_liquid_unstable_polymorph"
			else
				blood_material = Random() <= .5 and "magic_liquid_polymorph" or "magic_liquid_random_polymorph"
			end

			ComponentSetValue2(data.dmc, "blood_material", blood_material)
			ComponentSetValue2(data.dmc, "blood_spray_material", blood_material)
			ComponentSetValue2(data.dmc, "blood_multiplier", ComponentGetValue2(data.dmc, "blood_multiplier") * 1.5)
			EntitySetDamageFromMaterial(entity_id, blood_material, 0)
		end,
	},
	{
		id = "HOLY_REFLECTION",
		name = "$hardmod_eperk_holy_reflection_name",
		description = "$hardmod_eperk_holy_reflection_desc",
		weight = 3,
		max = 1,
		min_level = 8,
		func = function(self, entity_id, data)
			EntityAddComponent2(entity_id, "LuaComponent", {
				execute_every_n_frame = -1,
				script_damage_received = "data/scripts/animals/wraith_glowing_damage.lua",
				limit_to_every_n_frame = 10,
			})
		end
	},
	{
		id = "VIGOUR",
		name = "$hardmod_eperk_vigour_name",
		description = "$hardmod_eperk_vigour_desc",
		weight = 2,
		priority = 15,
		max = 1,
		max_level = 8,
		biome_conditions = {
			meat_realm = 0,
		},
		condition = spawn_on_death_blacklist,
		func = function(self, entity_id, data)
			-- make the enemy explode on death
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_death = dir.."scripts/vigour_on_death.lua",
				execute_every_n_frame = -1,
			})
		end
	},
	{
		id = "KAMIKAZE",
		name = "$hardmod_eperk_kamikaze_name",
		description = "$hardmod_eperk_kamikaze_desc",
		weight = 2,
		priority = 20,
		max = 1,
		max_level = 8,
		unique_slot = "on_death",
		biome_conditions = {
			coal_pits = 5,
		},
		condition = function(self, data)
			return spawn_on_death_blacklist(self, data) and enemy_is_melee(self, data) and not enemy_is_ranged_attack(self, data) and not (data.vigour or data.is_boss)
		end,
		func = function(self, entity_id, data)
			-- show nuke particles on the enemy
			local x, y = EntityGetTransform(entity_id)
			EntityAddChild(entity_id, EntityLoad(dir.."entities/kamikaze_particles.xml", x, y))

			-- make the enemy explode on death
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_death = dir.."scripts/kamikaze_on_death.lua",
				execute_every_n_frame = -1,
			})

			-- make the enemy explode when near the player
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_source_file = dir.."scripts/kamikaze_update.lua",
				execute_every_n_frame = 1,
			})

			-- make sure Vigour can't spawn
			data.kamikaze = true
		end
	},
	{
		id = "RATS_ON_DEATH",
		name = "$hardmod_eperk_rats_on_death_name",
		description = "$hardmod_eperk_rats_on_death_desc",
		weight = 3,
		biome_conditions = {
			snowy_depths = 5,
			hiisi_base = 4,
			temple_of_the_art = 2,
		},
		priority = 9,
		max = 3,
		max_level = 5,
		unique_slot = "on_death",
		condition = function(self, data) return spawn_on_death_blacklist(self, data) end,
		on_death = function(self, entity_id, ddata)
			for _=1, Random(3,5) do
				local eid = EntityLoad("data/entities/animals/rat.xml", ddata.x, ddata.y)
				EntityAddTag(eid,"felcesis_ignore")
				EntityAddComponent2(eid, "VariableStorageComponent", {_tags="no_gold_drop"})
				local dmc = EntityGetFirstComponent(eid, "DamageModelComponent")
				if dmc then ComponentSetValue2(dmc, "ragdoll_fx_forced", "DISINTEGRATED") end
			end
		end
	},
	{
		id = "SKULLRATS_ON_DEATH",
		name = "$hardmod_eperk_skullrats_on_death_name",
		description = "$hardmod_eperk_skullrats_on_death_desc",
		weight = 2,
		biome_conditions = { temple_of_the_art = 3 },
		priority = 9,
		max = 2,
		min_level = 3,
		max_level = 8,
		unique_slot = "on_death",
		condition = function(self, data) return spawn_on_death_blacklist(self, data) end,
		on_death = function(self, entity_id, ddata)
			for _=1, Random(2,4) do
				local eid = EntityLoad("data/entities/animals/skullrat.xml", ddata.x, ddata.y)
				EntityAddTag(eid,"felcesis_ignore")
			end
		end
	},
	{
		id = "SKULLFLYS",
		name = "$hardmod_eperk_skullflys_name",
		description = "$hardmod_eperk_skullflys_desc",
		weight = .5,
		biome_conditions = { temple_of_the_art = 1 },
		priority = 9,
		max = 3,
		min_level = 5,
		unique_slot = "on_death",
		condition = function(self, data) return spawn_on_death_blacklist(self, data) end,
		on_death = function(self, entity_id, ddata)
			for _=1, Random(1,3) do
				local eid = EntityLoad("data/entities/animals/skullfly.xml", ddata.x, ddata.y)
				EntityAddTag(eid,"felcesis_ignore")
			end
		end,
	},
	{
		id = "BLACKHOLE_DEATH",
		name = "$hardmod_eperk_blackhole_death_name",
		description = "$hardmod_eperk_blackhole_death_desc",
		weight = .5,
		priority = 15,
		max = 1,
		min_level = 4,
		max_level = 10,
		unique_slot = "on_death",
		biome_conditions = {
			hell = 2,
		},
		condition = function(self, data) return spawn_on_death_blacklist(self, data) and not data.is_boss end,
		on_death = function(self, entity_id, ddata)
			EntityLoad("data/entities/projectiles/deck/black_hole_big.xml", ddata.x, ddata.y)
		end
	},
	{
		id = "WHITEHOLE_DEATH",
		name = "$hardmod_eperk_whitehole_death_name",
		description = "$hardmod_eperk_whitehole_death_desc",
		weight = .5,
		priority = 15,
		max = 1,
		min_level = 4,
		max_level = 10,
		unique_slot = "on_death",
		biome_conditions = {
			sky = 2,
		},
		condition = function(self, data) return spawn_on_death_blacklist(self, data) and not data.is_boss end,
		on_death = function(self, entity_id, ddata)
			EntityLoad("data/entities/projectiles/deck/white_hole_big.xml", ddata.x, ddata.y)
		end
	},
	{
		id = "OMEGA_BLACKHOLE_DEATH",
		name = "$hardmod_eperk_omega_blackhole_death_name",
		description = "$hardmod_eperk_omega_blackhole_death_desc",
		weight = .5,
		priority = 15,
		max = 1,
		min_level = 11,
		unique_slot = "on_death",
		biome_conditions = {
			sky = 2,
		},
		condition = function(self, data) return spawn_on_death_blacklist(self, data) and not data.is_boss end,
		on_death = function(self, entity_id, ddata)
			EntityLoad("data/entities/projectiles/deck/black_hole_giga.xml", ddata.x, ddata.y)
		end
	},
	{
		id = "OMEGA_WHITEHOLE_DEATH",
		name = "$hardmod_eperk_omega_whitehole_death_name",
		description = "$hardmod_eperk_omega_whitehole_death_desc",
		weight = .5,
		priority = 15,
		max = 1,
		min_level = 11,
		unique_slot = "on_death",
		biome_conditions = {
			sky = 2,
		},
		condition = function(self, data) return spawn_on_death_blacklist(self, data) and not data.is_boss end,
		on_death = function(self, entity_id, ddata)
			EntityLoad("data/entities/projectiles/deck/white_hole_giga.xml", ddata.x, ddata.y)
		end
	},
	{
		id = "WORM_FLIGHT",
		name = "$hardmod_eperk_worm_flight_name",
		description = "$hardmod_eperk_worm_flight_desc",
		weight = 10,
		priority = 5,
		max = 1,
		condition = function(self, data)
			return EntityGetFirstComponent(data.target_enemy, "WormComponent")
		end,
		func = function(self, entity_id, data)
			local worming_it_flight_style = EntityGetFirstComponent(entity_id, "WormComponent")
			if not worming_it_flight_style then return --[[ :( ]] end

			ComponentSetValue2(worming_it_flight_style, "gravity", 0)
		end
	},
	{
		id = "OBFUSCATION",
		name = "$hardmod_eperk_obfuscation_name",
		description = "$hardmod_eperk_obfuscation_desc",
		weight = 2,
		priority = 100,
		max = 1,
		min_level = 3,
		condition = function(self, data)
			return (#data.already_held_perks + data.perks_to_give) > 1
		end,
		func_handler = function(self, entity_id, root, spr_comps)
			for _,spr_comp in ipairs(spr_comps) do
				local exceptions = {
					[dir.."perk_icons/expand.png"] = true,
					[dir.."perk_icons/obfuscation.png"] = true,
				}
				if not exceptions[ComponentGetValue2(spr_comp, "image_file")] then
					ComponentSetValue2(spr_comp, "image_file", dir.."perk_icons/missing.png")
					EntityRefreshSprite(entity_id, spr_comp)
				end
			end
		end,
		func_inspector = function(self, perks)
			for _,perk in ipairs(perks) do
				if perk ~= self then perk.sprite = dir.."perk_sprites/missing.png" end
			end
		end
	},
	{
		id = "BOUNTY",
		name = "$hardmod_eperk_bounty_name",
		description = "$hardmod_eperk_bounty_desc",
		weight = 1,
		priority = 30,
		max = 1,
		min_level = 5,
		unique_slot = "on_death",
		condition = function(self, data) return data.perks_to_give end,
		func = function(self, entity_id, data)
			data.perks_to_give = data.perks_to_give + 10
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_death = dir.."scripts/drop_chest_on_death.lua"
			})
		end
	},
	{
		id = "SHIELD_SAPPER",
		name = "$hardmod_eperk_shield_sapper_name",
		description = "$hardmod_eperk_shield_sapper_desc",
		weight = 2,
		max = 1,
		min_level = 4,
		unique_slot = "large_aura",
		biome_conditions = {
			magical_temple = 4,
			temple_of_the_art = 6,
			wizards_den = 6,
			sky = 6,
			hell = 6,
		},
		condition = increment_weight_with_level,
		func = function(self, entity_id, data)
			local x, y = EntityGetTransform(entity_id)
			EntityAddChild(entity_id, EntityLoad( dir.."entities/shield_sapper_aura.xml", x, y))
		end
	},
	{
		id = "UNSTABLE_TELEPORTITIS",
		name = "$hardmod_eperk_unstable_teleportitis_name",
		description = "$hardmod_eperk_unstable_teleportitis_desc",
		weight = 2,
		max = 1,
		min_level = 3,
		func = function(self, entity_id, data)
			local eid = EntityCreateNew("random_teleports")
			EntityAddComponent2(eid, "GameEffectComponent", {
				effect = "TELEPORTATION",
				frames = -1,
				teleportation_probability = 50,
				teleportation_delay_min_frames = 120,
				teleportation_radius_max = 100,
			})
			EntityAddChild(entity_id, eid)
		end
	},
	ideal_form_perk,
	--{ --I'll implement this later, or someone can do it for me 🙏
	--	not_progress = true,
	--	id = "VENOMOUS_CURSER",
	--	name = "$hardmod_eperk_venomous_curser_name",
	--	description = "$hardmod_eperk_venomous_curser_desc",
	--	weight = 0,
	--	priority = 0,
	--	max = 0,
	--	condition = enemy_is_ranged_attack,
	--	func = function(self, entity_id, data)
	--		EntityAddComponent2(entity_id, "LuaComponent", {
	--			script_shot = dir.."scripts/venomous_curser_shot.lua",
	--			execute_every_n_frame = -1,
	--		})
	--	end
	--},
	--{
	--	id = "ARMED",
	--	name = "$hardmod_eperk_armed_name",
	--	description = "$hardmod_eperk_armed_desc",
	--	weight = 7,
	--	max = 0,
	--	condition = function(self, data)
	--		return data.level > 1 --can hold gun
	--	end,
	--	func = function(self, entity_id, data)
	--		local wands = dofile_once(dir.."scripts/armed_wands_list.lua")
	--		local new_data = utils.deepcopy(data)
	--		new_data.perk = self
	--		local wand_data = utils.ConditionalRandomFromTable(wands, new_data)
	--		if not wand_data then return end

	--		local wand = EntityLoad("", data.x, data.y)
	--		GamePickUpInventoryItem(entity_id, wand)
	--	end,
	--},
	--{ --ill implement these two later
	--	id = "POLYMORPH_AURA",
	--	name = "$hardmod_eperk_polymorph_aura_name",
	--	description = "$hardmod_eperk_polymorph_aura_desc",
	--	weight = 3,
	--	max = 0,
	--	condition = function(self, data) increment_weight_with_level(self, data, -.2) end,
	--	func = function(self, entity_id, data)
	--		EntityAddChild(entity_id, EntityLoad(dir.."entities/polymorph_aura", data.x, data.y))
	--	end
	--},
	--{
	--	id = "UNFINISHED_BUSINESS",
	--	name = "$hardmod_eperk_unfinited_business_name",
	--	description = "$hardmod_eperk_unfinited_business_desc",
	--	weight = 2,
	--	max = 0,
	--	func = function(self, entity_id, data)
	--		EntityAddChild(entity_id, EntityLoad(dir.."entities/polymorph_aura", data.x, data.y))
	--	end
	--},
	-- this one needs a player-only berserk effect (doable but cba rn)
	-- {
	-- 	id = "SHORT_TEMPER",
	-- 	name = "$hardmod_eperk_short_temper_name",
	-- 	description = "$hardmod_eperk_short_temper_desc",
	-- 	weight = 400,
	-- 	priority = 10,
	-- 	max = 1,
	-- 	func = function(self, entity_id, data)
	-- 		EntityAddComponent2(entity_id, "LuaComponent", {
	-- 			script_damage_received = "mods/noita.hardmod/files/modules/enemy_perks/scripts/short_temper_on_damage.lua",
	-- 			execute_every_n_frame = -1,
	-- 		})
	-- 	end
	-- },
	{
		id = "UNDETECTABLE",
		name = "$hardmod_eperk_undetectable_name",
		description = "$hardmod_eperk_undetectable_desc",
		weight = 5,
		priority = 10,
		max = 1,
		min_level = 3,
		func = function(self, entity_id, data)
			EntityRemoveTag(entity_id, "homing_target")
		end
	},
	{
		id = "ALL_SEEING",
		name = "$hardmod_eperk_all_seeing_name",
		description = "$hardmod_eperk_all_seeing_desc",
		weight = 0,
		priority = 24,
		max = 2,
		biome_conditions = {
			magical_temple = 4,
			temple_of_the_art = 4,
			wizards_den = 4,
			tower = 4,
			sky = 4,
			hell = 4,
		},
		condition = function(self, data)
			-- this perk can only appear on mages, ghosts (excl. wand ghosts) and some select enemies
			local factions = "mage,mage_swapper,ghost,"
			local creatures = { "monk", }

			local strparts = split_string(EntityGetFilename(data.target_enemy),"/")
			local filename = strparts[#strparts]
			local filename_match = false
			for _,creature_name in ipairs(creatures) do
				if string.find(filename, creature_name) then
					filename_match = true
				end
			end
			return enemy_is_ranged_attack(self, data)
				and (string.find(factions, HerdIdToString(utils.GetHerdID(data.target_enemy)))
				or filename_match) and not EntityHasTag(data.target_enemy, "wand_ghost")
		end,
		func = function(self, entity_id, data)
			local animal_comp = EntityGetFirstComponent(entity_id, "AnimalAIComponent")
			if animal_comp then
				ComponentSetValue2(animal_comp, "sense_creatures", true)
				ComponentSetValue2(animal_comp, "sense_creatures_through_walls", true)
			end
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_source_file = dir.."scripts/all_seeing_scan.lua",
				execute_every_n_frame = 15,
			})
			EntityAddComponent2(entity_id, "LuaComponent", {
				script_shot = dir.."scripts/all_seeing_on_shot.lua",
				execute_every_n_frame = -1,
			})

			local stacks = (data.how_many_of_each_perk[self.id] or 0) + 1
			if stacks == 2 then
				EntityAddComponent2(entity_id, "VariableStorageComponent", {
					name = "hardmod_all_seeing_radius",
					value_int = 150,
				})
			end
		end
	},
	{
		id = "TETHER",
		name = "$hardmod_eperk_tether_name",
		description = "$hardmod_eperk_tether_desc",
		weight = 1,
		priority = 25,
		max = 2,
		min_level = 6,
		unique_slot = "large_aura",
		biome_conditions = {
			temple_of_the_art = 2,
			wizards_den = 2,
			sky = 4,
			hell = 4,
			tower = 4,
		},
		condition = function(self, data)
			if not data.dmc then return end
			return ComponentGetValue2(data.dmc, "max_hp") >= 3
		end,
		func = function(self, entity_id, data)
			local x, y = EntityGetTransform(entity_id)
			EntityAddChild(entity_id, EntityLoad( dir.."entities/tether_aura_dormant.xml", x, y))

			local stacks = (data.how_many_of_each_perk[self.id] or 0) + 1
			if stacks == 2 then
				local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils
				utils.SetInternalInt( entity_id, "hardmod_tether_stacks", stacks )
			end
		end
	},
	{
		id = "ANTI_TELE_AURA",
		name = "$hardmod_eperk_anti_tele_aura_name",
		description = "$hardmod_eperk_anti_tele_aura_desc",
		weight = 2,
		priority = 23,
		max = 1,
		min_level = 6,
		unique_slot = "large_aura",
		func = function(self, entity_id, data)
			local x, y = EntityGetTransform(entity_id)
			EntityAddChild(entity_id, EntityLoad( dir.."entities/anti_tele_aura.xml", x, y))
		end
	},
}

for i,perk in ipairs(enemy_perks) do
	local id = perk.id
	perk.id = "HARDMOD_"..perk.id
	perk.name = perk.name or perk.id
	perk.weight = (perk.weight or 10) + i*0.001
	perk.priority = perk.priority or 0
	perk.sprite = ModDoesFileExist(perk.sprite or "") and perk.sprite
		or ModDoesFileExist(sprites_path..id:lower()..".png") and sprites_path..id:lower()..".png"
		or "mods/noita.hardmod/files/modules/enemy_perks/perk_sprites/missing.png"
	perk.icon = ModDoesFileExist(perk.icon or "") and perk.icon
		or ModDoesFileExist(icons_path..id:lower()..".png") and icons_path..id:lower()..".png"
		or "mods/noita.hardmod/files/modules/enemy_perks/perk_icons/missing.png"

	if perk.max then --This is sane enough.
		local cond = perk.condition or function(...) return true end
		perk.condition = function(self, data, ...)
			return cond(self, data, ...) and (data.how_many_of_each_perk[self.id] or 0) < self.max
		end
	end

	if perk.biome_conditions then
		local cond = perk.condition or function(...) return true end
		perk.condition = function(self, data, ...)
			local biome_condition = self.biome_conditions[data.biome]
			local biome_condition_type = type(biome_condition)
			if biome_condition_type == "number" then
				self.weight = biome_condition
			elseif biome_condition_type == "function" then
				return biome_condition(self, data, ...) and cond(self,data, ...)
			end
			return cond(self, data, ...)
		end
	end

	perk.func = perk.func or function(...) end
end

--[[
local ignore_perks = {
	HARDMOD_WORM_FLIGHT = true
}
local total_weight = 0
local perks = {}
for _,perk in ipairs(enemy_perks) do
	if not ignore_perks[perk.id] then
		perks[#perks+1] = {perk.id, perk.weight}
		total_weight = total_weight + perk.weight
	end
end
table.sort(perks, function(a,b) return a[2] > b[2] end)
for _,perk in pairs(perks) do
	print(("%s: %s%%"):format(perk[1], perk[2]*100/total_weight))
end
--]]

eperk_utils = dofile_once("mods/noita.hardmod/files/modules/enemy_perks/eperk_utilities.lua")(enemy_perks) ---@type eperk_utils

return enemy_perks
