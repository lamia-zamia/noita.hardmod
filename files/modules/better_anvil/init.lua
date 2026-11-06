local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua")---@type nxml
local root = "mods/noita.hardmod/files/modules/better_anvil"

local function patch_broken_wand()
	utils.modifile(
		"data/scripts/items/broken_wand_throw.lua",
		[[spell_amount = 18]], [[spell_amount = 27]]
	)

	local search = "shoot_projectile( entity_id, spell, pos_x, pos_y, vel_x, vel_y)"
	utils.modifile(
		"data/scripts/items/broken_wand_spells.lua",
		search,
		"local thrown_projectile = " .. search .. [[
			EntityAddComponent2(thrown_projectile, "HomingComponent", {
				_tags = "homing_projectile",
				homing_targeting_coeff = 130.0,
				homing_velocity_multiplier = 0.86,
				detect_distance = 300,
				predefined_target = 0
			})
		]]
	)
end

local forge_item_convert = "data/scripts/buildings/forge_item_convert.lua"
local function patch_forge_convert()
	utils.modifile(
		forge_item_convert,
		[[EntityLoad("data/entities/items/wand_level_05_better.xml", x, y - 5)]],
		[[dofile("mods/noita.hardmod/files/modules/better_anvil/forge/repaired_wand.lua")(x, y)]]
	)
end

local function patch_broken_spell()
	utils.modifile(
		forge_item_convert,
		[[CreateItemActionEntity( "SUMMON_PORTAL", x, y)]],
		[[dofile("mods/noita.hardmod/files/modules/better_anvil/forge/repaired_spell.lua")(x, y)]]
	)

	ModLuaFileAppend("data/scripts/item_spawnlists.lua", root.."/appends/item_spawnlists.lua")

	for broken_spell in nxml.edit_file("data/entities/items/pickup/summon_portal_broken.xml") do
		local icomp = broken_spell:first_of("ItemComponent")
		if icomp then
			icomp:set("preferred_inventory", "FULL")
			icomp:set("play_spinning_animation", false)
		end

		local comps = { "ParticleEmitterComponent", "LightComponent", "SpriteComponent", "SpriteParticleEmitterComponent" }
		for _,name in pairs(comps) do
			for comp in broken_spell:each_of(name) do
				local tags = comp:get("_tags")
				tags = tags and tags .. "," or ""

				comp:set("_tags", tags .. "not_enabled_in_wand")
			end
		end

		broken_spell:set("tags", broken_spell:get("tags") .. ",not_enabled_in_wand")
		broken_spell:create_child("ItemActionComponent", {
			_tags = "enabled_in_world",
			action_id = "HARDMOD_BROKEN_SPELL",
		})
	end
end

local function patch_random_forge_location()
	local location = dofile_once("mods/noita.hardmod/files/modules/better_anvil/forge/location.lua")

	for ps in nxml.edit_file("data/biome/_pixel_scenes.xml") do
		local scenes = ps:first_of("mBufferedPixelScenes")
		if not scenes then return end

		local orig_color_file = "data/biome_impl/snowcastle/forge_visual.png"
		for child in scenes:each_child() do
			if child:get("colors_filename") == orig_color_file then
				child:set("background_filename", root.."/gfx/old_forge/background.png")
				child:set("colors_filename", root.."/gfx/old_forge/visual.png")
				child:set("material_filename", root.."/gfx/old_forge/material.png")
				break
			end
		end

		-- TODO: Please tell me if there's a better way to do this...
		scenes:create_child("PixelScene", {
			DEBUG_RELOAD_ME = false, clean_area_before = true,
			skip_biome_checks = true, skip_edge_textures = false,
			background_filename = root.."/gfx/new_forge/background.png",
			colors_filename = root.."/gfx/new_forge/visual.png",
			material_filename = root.."/gfx/new_forge/material.png",
			pos_x = location.x,
			pos_y = location.y,
		})
	end
end

patch_broken_wand()
patch_forge_convert()
patch_broken_spell()

ModLuaFileAppend("data/scripts/biomes/snowcastle.lua", root.."/appends/snowcastle.lua")

return {
	magic_numbers_and_seed_initialised = function()
		patch_random_forge_location()
	end
}