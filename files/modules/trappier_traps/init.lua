local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml
local imutil = dofile_once("mods/noita.hardmod/lib/image_utils.lua") ---@type image_utils

ModLuaFileAppend("data/scripts/biomes/temple_altar_top_shared.lua", "mods/noita.hardmod/files/modules/trappier_traps/portal_basin/generate.lua")

-- I thought that'd work...
-- imutil.ImageOverlay(
-- 	"data/biome_impl/coalmine/wandtrap_h_02.png",
-- 	"mods/noita.hardmod/files/modules/trappier_traps/gfx/wandtrap_h_02.png"
-- )

-- the traps are trappier than before :)

local igniters = {"data/entities/props/physics/trap_ignite.xml", "data/entities/props/physics/trap_ignite_enabled.xml", "data/entities/props/physics_trap_ignite.xml", "data/entities/props/physics_trap_ignite_enabled.xml"}
for _, file in ipairs(igniters)do
	for entity in nxml.edit_file(file) do
		-- ignite instantly? mayhaps
		-- upd: this defeats the point of the trap cuz it just instantly burns the liquid
		-- for i = #entity.children, 1, -1 do
		-- 	if entity.children[i]:get("script_source_file") == "data/scripts/props/physics_trap_ignite.lua" then
		-- 		entity.children[i]:set("execute_every_n_frame", 1)
		-- 	end
		-- end
		
		-- stop kick cheesing traps
		local physics_body_comp = entity:first_of("PhysicsBodyComponent")

		if(physics_body_comp)then
			physics_body_comp:set("is_static", true)
		end

		local physics_body2_comp = entity:first_of("PhysicsBody2Component")

		if(physics_body2_comp)then
			physics_body2_comp:set("is_static", true)
		end
	end
end

-- Disabled cause this broke a puzzle in the mines
-- local electifiers = {"data/entities/props/physics/trap_electricity.xml", "data/entities/props/physics/trap_electricity_enabled.xml", "data/entities/props/physics/trap_electricity_suspended.xml", "data/entities/props/physics_trap_electricity.xml", "data/entities/props/physics_trap_electricity_enabled.xml"}
-- for _, file in ipairs(electifiers)do
-- 	for entity in nxml.edit_file(file) do
-- 		-- This might be too evil but honestly.. I hate how easily electrical traps are cheesed.
-- 		for i = #entity.children, 1, -1 do
-- 			if entity.children[i]:get("script_source_file") == "data/scripts/props/physics_trap_electricity_pulse.lua" then
-- 				entity.children[i]:set("execute_every_n_frame", entity.children[i]:get("execute_every_n_frame") / 3)
-- 			end
-- 		end
		
-- 		local physics_body_comp = entity:first_of("PhysicsBodyComponent")

-- 		if(physics_body_comp)then
-- 			physics_body_comp:set("is_static", true)
-- 		end

-- 		local physics_body2_comp = entity:first_of("PhysicsBody2Component")

-- 		if(physics_body2_comp)then
-- 			physics_body2_comp:set("is_static", true)
-- 		end
-- 	end
-- end

local acid_traps = {"data/entities/props/physics/trap_circle_acid.xml", "data/entities/props/physics_trap_circle_acid.xml"}

for _, file in ipairs(acid_traps)do
	for entity in nxml.edit_file(file) do
		-- Make them unkickable, why does nolla let you get away with this.
		local physics_body_comp = entity:first_of("PhysicsBodyComponent")

		if(physics_body_comp)then
			physics_body_comp:set("is_static", true)
		end

		local physics_body2_comp = entity:first_of("PhysicsBody2Component")

		if(physics_body2_comp)then
			physics_body2_comp:set("is_static", true)
		end
	end
end

local tota_traps = {"data/entities/buildings/arrowtrap_left.xml", "data/entities/buildings/arrowtrap_right.xml", "data/entities/buildings/firetrap_left.xml", "data/entities/buildings/firetrap_right.xml", "data/entities/buildings/thundertrap_left.xml", "data/entities/buildings/thundertrap_right.xml", "data/entities/buildings/spittrap_left.xml", "data/entities/buildings/spittrap_right.xml",}
local projectile_mappings = {
	["data/entities/projectiles/arrow.xml"] = "mods/noita.hardmod/files/modules/trappier_traps/arrow.xml",
	["data/entities/projectiles/fire_trap.xml"] = "mods/noita.hardmod/files/modules/trappier_traps/fire_trap.xml",
	["data/entities/projectiles/spit_trap.xml"] = "mods/noita.hardmod/files/modules/trappier_traps/spit_trap.xml",
	["data/entities/projectiles/thunder_trap.xml"] = "mods/noita.hardmod/files/modules/trappier_traps/thunder_trap.xml",
}
for _, file in ipairs(tota_traps)do
	-- I feel like this shit is not working i was trying to make them shotgun the projectiles in like a 30 degree arc or some shit but it just won't
	for entity in nxml.edit_file(file) do
		local damage_model_comp = entity:first_of("DamageModelComponent")
		local animal_ai_comp = entity:first_of("AnimalAIComponent")

		if(damage_model_comp)then
			damage_model_comp:set("hp", tonumber(damage_model_comp:get("hp")) * 4)
		end

		if(animal_ai_comp)then
			animal_ai_comp:set("creature_detection_angular_range_deg", 30)
			animal_ai_comp:set("attack_ranged_entity_count_min", 3)
			animal_ai_comp:set("attack_ranged_entity_count_max", 5)
			animal_ai_comp:set("attack_ranged_entity_file", projectile_mappings[animal_ai_comp:get("attack_ranged_entity_file")])
		end
	end
end

return {}
