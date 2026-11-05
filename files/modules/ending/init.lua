local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

for file in nxml.edit_file("data/entities/animals/boss_centipede/sampo.xml") do
	local item = file:first_of("ItemComponent")
	if item then file:remove_child(item) end

	local phys = file:first_of("SimplePhysicsComponent")
	if phys then file:remove_child(phys) end

	for emitter in file:each_of("ParticleEmitterComponent") do
		if emitter:get("emitted_material_name") == "spark_blue" then
			emitter:set("emitted_material_name", "spark_white_bright")
		end
	end

	local area_checker = file:first_of("MaterialAreaCheckerComponent")
	if area_checker then
		file:remove_child(area_checker)
	end

	local sprite = file:first_of("SpriteComponent")
	if sprite then
		sprite:set("image_file", "mods/noita.hardmod/files/modules/ending/gfx/sampo_sprite_locked.xml")
	end

	file:create_child("InteractableComponent", {
		_enabled = true,
		_tags = "enabled_in_world",
		ui_text = "-",
		name = "pickup_sampo",
		radius = 14.1
	})

	file:create_child("LuaComponent", {
		script_interacting = "mods/noita.hardmod/files/modules/ending/sampo_logic.lua",
		script_source_file = "mods/noita.hardmod/files/modules/ending/sampo_logic.lua",
		execute_every_n_frame = 120,
	})
end

-- very basic idea, i didnt expect it to work but ok
local function goldify_wands()
	local wands = {
		{ "data/items_gfx/handgun.xml", "handgun" },
		{ "data/items_gfx/bomb_wand.xml", "bomb_wand" },
	}

	for _,wand in pairs(wands) do
		for file in nxml.edit_file(wand[1]) do
			file:set("filename", "mods/noita.hardmod/files/modules/ending/gfx/gold_wands/"..wand[2]..".png")
		end
	end
end

utils.modifile(
	"data/scripts/biomes/boss_arena.lua",
	[[sampo.xml", x, y + 80 )]],
	[[sampo.xml", x, y + 90); EntityLoad("mods/noita.hardmod/files/modules/ending/entities/book_hint.xml", x - 145, y - 40)]]
)

utils.patchifile("data/entities/animals/boss_centipede/ending/sampo_start_ending_sequence.lua", {
	{
		from = [[GameOnCompleted()]],
		insert_before = [[
			AddFlagPersistent("hardmod_game_completed")
		]]
	}
})

if HasFlagPersistent("hardmod_game_completed") then
	goldify_wands()
end

-- I fucking hate this shit why does it not work???????????????
-- local function patch_material_hint()
--   for file in nxml.edit_file("data/biome/_pixel_scenes.xml") do
--     local root = "mods/noita.hardmod/files/modules/ending/gfx/"

--     local scenes = file:first_of("mBufferedPixelScenes")
--     if not scenes then return end
    
--     scenes:create_child("PixelScene", {
--       DEBUG_RELOAD_ME = false, clean_area_before = true,
--       skip_biome_checks = true, skip_edge_textures = false,
--       material_filename = root.."ending_materials_hint.png",
--       background_filename = "",
--       colors_filename = "",
--       pos_x = 3430, pos_y = 13103,
--     })

--     scenes:create_child("PixelScene", {
--       DEBUG_RELOAD_ME = false, clean_area_before = true,
--       skip_biome_checks = true, skip_edge_textures = false,
--       material_filename = root.."ending_materials_hint_right.png",
--       background_filename = "",
--       colors_filename = "",
--       pos_x = 3430 + 160, pos_y = 13103,
--     })
--   end
-- end

-- patch_material_hint()

return {}
