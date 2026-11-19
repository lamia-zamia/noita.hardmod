local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua")---@type nxml
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local alt_biomes = dofile_once("mods/noita.hardmod/files/modules/alternate_biomes/biome_list.lua")

utils.AddEnemyToProgress("hardmod_wizard_confusion", "wizard_twitchy")
utils.AddEnemyToProgress("hardmod_mummy", "icer")

local function patch_spawn_rules()
	local patch_biomes = {
		"coalmine_alt",
		"coalmine",
		"crypt",
		"desert",
		"excavationsite",
		"fungicave",
		"fungiforest",
		"rainforest_dark",
		"rainforest",
		"sandcave",
		"snowcastle",
		"snowcave",
		"the_end",
		"vault",
		"wandcave",
		"winter",
		"wizardcave",
	}

	for _,biome in ipairs(patch_biomes) do
		local append = table.concat({"mods/noita.hardmod/files/modules/stronger_enemies/biomes/",biome,".lua"})
		ModLuaFileAppend("data/scripts/biomes/" .. biome .. ".lua", append)
	end

	for _,alt in ipairs(alt_biomes) do
		local append = table.concat({"mods/noita.hardmod/files/modules/stronger_enemies/biomes/",alt.replaces,".lua"})
		if ModDoesFileExist(append) then ModLuaFileAppend(alt.script, append) end
	end

	ModLuaFileAppend("data/scripts/director_helpers.lua", "mods/noita.hardmod/files/modules/stronger_enemies/appends/director_helpers.lua")
end

local function patch_enemy_changes()
	utils.patchifile("data/scripts/animals/spirit_aura_weak.lua", {
		{
			from = [["GameEffectComponent", "spirit_weakness"]],
			to = [["VariableStorageComponent", "hardmod_spirit_weaken"]]
		},
		{
			from = [[EntityGetInRadiusWithTag( x, y, r, "homing_target" )]],
			to = [[{}]]
		},
		{
			from = [[data/entities/misc/effect_spirit_weakness.xml]],
			to = [[mods/noita.hardmod/files/modules/stronger_enemies/entities/effect_spirit_weaken.xml]]
		},
		{
			from = [[EntityAddChild]],
			insert_before = [[
				AddFlagPersistent("hardmod_found_spirit_weaken")
			]]
		}
	})

	for xml in nxml.edit_file("data/entities/animals/weakspirit.xml") do
		xml:add_child(nxml.new_element("ParticleEmitterComponent", {
			["emitted_material_name"]="plasma_fading",
			["gravity.y"]="0.0",
			["lifetime_min"]="0.02",
			["lifetime_max"]="0.05",
			["count_min"]="90",
			["count_max"]="170",
			["render_on_grid"]="1",
			["fade_based_on_lifetime"]="1",
			["area_circle_radius.min"]="220",
			["area_circle_radius.max"]="220",
			["cosmetic_force_create"]="0",
			["airflow_force"]="0.3",
			["airflow_time"]="0.01",
			["airflow_scale"]="0.05",
			["emission_interval_min_frames"]="0",
			["emission_interval_max_frames"]="0",
			["emit_cosmetic_particles"]="1",
			["is_emitting"]="1",
			["custom_alpha"]="0.7",
		}))
	end

	utils.patchifile("data/entities/projectiles/orb_poly.xml", {
		{ from = [[damage="0.3"]], to=[[damage="0"]] },
		{ from = [[damage = "0.1"]], to=[[damage="0"]] },
	})

	local hiisi = {
		"shotgunner",
		"shotgunner_hell",
		"scavenger_clusterbomb",
		"scavenger_grenade",
		"scavenger_glue",
		"scavenger_mine",
		"scavenger_poison",
		"scavenger_smg",
		"scavenger_leader",
		"goblin_bomb",
	}

	for _,name in pairs(hiisi) do
		for file in nxml.edit_file("data/entities/animals/"..name..".xml") do
			local base = file:first_of("Base")
			if not base then break end

			local aicomp = base:first_of("AnimalAIComponent")
			if not aicomp then break end

			aicomp:set("creature_detection_angular_range_deg", 90)
		end
	end
end

local function patch_enemy_resistances()
	local elec_imm = {
		"shotgunner_hell",
		"sniper_hell",
		"miner_hell",
		"scavenger_leader",
		"scavenger_poison",
		"scavenger_clusterbomb",
	}

	for _,enemy in pairs(elec_imm) do
		for file in nxml.edit_file("data/entities/animals/"..enemy..".xml") do
			file:create_child("Entity", {}, {
				nxml.new_element("InheritTransformComponent"),
				nxml.new_element("GameEffectComponent", {
					effect = "PROTECTION_ELECTRICITY",
					frames = -1
				})
			})
		end
	end
end

local function patch_less_annoyances()
	-- This does make the blinding effect easier, but patch_spawn_rules adds more blinding mages
	-- (in e.g. collapsed mines and coal pits) so i think that's a fair tweak
	-- 20s -> 12s
	for file in nxml.edit_file("data/entities/misc/effect_blindness.xml") do
		local effect = file:first_of("GameEffectComponent")
		if effect then
			effect:set("frames", 720)
		end
	end
	-- you can see more, but the visible area is darker
	utils.modifile(
		"data/shaders/post_final.frag",
		[[overlay_color_blindness.a * edge_dist*edge_dist * 40.0]],
		[[overlay_color_blindness.a * edge_dist*edge_dist * 2.0]]
	)

	-- idk about you but i hate these guys
	for file in nxml.edit_file("data/entities/animals/confusespirit.xml") do
		local dmc = file:first_of("Base"):first_of("DamageModelComponent")
		if dmc then
			dmc:set("hp", 1)
			dmc:first_of("damage_multipliers"):set("projectile", 1)
		end
	end
end

local function patch_fixes()
	-- swappem (makes homing even more dangerous, especially with swappers being in more biomes)
	for file in nxml.edit_file("data/entities/animals/wizard_swapper.xml") do
		for luacomp in file:first_of("Base"):each_of("LuaComponent") do
			if luacomp:get("script_damage_received") then
				luacomp:set("limit_how_many_times_per_frame", 1)
				luacomp:set("limit_all_callbacks", true)
			end
		end
	end
end

patch_spawn_rules()
patch_less_annoyances()
patch_fixes()
patch_enemy_changes()
patch_enemy_resistances()

return {
	player_spawned = function()
		-- EntityLoad("mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_wizard_confusion.xml", 627, -125)
	end
}
