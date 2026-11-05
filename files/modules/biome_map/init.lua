local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local imutil = dofile_once("mods/noita.hardmod/lib/image_utils.lua") ---@type image_utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua")---@type nxml

local hooks = {} ---@type hooks

local custom_biomes = {
	{ h = 2, color = "ffde88e3", file = "secret_lab_path.xml" },
	{ h = 0, color = "ffff56a5", file = "pw_barrier.xml" },
	{ h = 0, color = "ffffe098", file = "cheese/biome.xml" },
}

for file in nxml.edit_file("data/biome/_biomes_all.xml") do
	for _,biome in pairs(custom_biomes) do
		file:create_child("Biome", {
			biome_filename = "mods/noita.hardmod/files/modules/biome_map/biome/" .. biome.file,
			height_index = biome.h,
			color = biome.color
		})
	end
end

for file in nxml.edit_file("data/biome/_pixel_scenes.xml") do
	local ps = file:first_of("PixelSceneFiles")
	if not ps then break end

	for _,entry in pairs(ps:all_of("File")) do
		local path = ""
		for i=1,#entry.content,1 do
			path = path .. entry.content[i]
		end

		if path == "data/biome_impl/spliced/lavalake_pit_bottom.xml" then
			ps:remove_child(entry)
		end
	end
end

for file in nxml.edit_file("data/biome_impl/spliced/gourd_room.xml") do
	local ps = file:first_of("mBufferedPixelScenes")
	if not ps then break end

	-- move gourd room from the cloudscape (chunk Y=-6656) to the lake (chunk Y=0)
	local offset = 6656

	for scene in ps:each_of("PixelScene") do
		local y = tonumber(scene:get("pos_y"))
		if y then
			scene:set("pos_y", y + offset)
		end
	end
end

ModMagicNumbersFileAdd("mods/noita.hardmod/files/modules/biome_map/magic_numbers.xml")
utils.modifile(
	"data/scripts/biomes/snowcastle_cavern.lua",
	[[local is_right = ]],
	[[local is_right = true --]]
)

imutil.ImageOverlay("data/biome_impl/robot_egg.png", "mods/noita.hardmod/files/modules/biome_map/gfx/robot_egg.png")

ModMaterialsFileAdd("mods/noita.hardmod/files/modules/biome_map/materials.xml")

function hooks.player_spawned(p, is_run_start)
	if is_run_start then
		EntitySetDamageFromMaterial(p, "hardmod_cursed_liquid", 0.003)
	end
end

return hooks
