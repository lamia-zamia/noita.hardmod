local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua")---@type nxml
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

utils.AddEnemyToProgress("hardmod_wizard_confusion", "wizard_twitchy")

local function patch_spawn_rules()
	local patch_biomes = {
		"coalmine_alt",
		"crypt",
		"excavationsite",
		"fungicave",
		"fungiforest",
		"rainforest_dark",
		"rainforest",
		"snowcastle",
		"snowcave",
		"the_end",
		"vault",
		"wandcave",
		"winter",
		"wizardcave",
	}

	for _,biome in pairs(patch_biomes) do
		ModLuaFileAppend(
		"data/scripts/biomes/" .. biome .. ".lua",
		"mods/noita.hardmod/files/modules/stronger_enemies/biomes/" .. biome .. ".lua"
		)
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
			from = [[data/entities/misc/effect_spirit_weakness.xml]],
			to = [[mods/noita.hardmod/files/modules/stronger_enemies/entities/effect_spirit_weaken.xml]]
		},
	})

	utils.patchifile("data/entities/projectiles/orb_poly.xml", {
		{ from = [[damage="0.3"]], to=[[damage="0"]] },
		{ from = [[damage = "0.1"]], to=[[damage="0"]] },
	})
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

return {
	player_spawned = function()
		-- EntityLoad("mods/noita.hardmod/files/modules/stronger_enemies/entities/hardmod_wizard_confusion.xml", 627, -125)
	end
}
