local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local imutil = dofile_once("mods/noita.hardmod/lib/image_utils.lua") ---@type image_utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua")---@type nxml

local hooks = {} ---@type hooks

local biome_map_path = "mods/noita.hardmod/files/modules/biome_map/biome_map.lua"

local custom_biomes = {
	{ h = 2, color = "ffde88e3", file = "secret_lab_path.xml" },
	{ h = 0, color = "ffff56a5", file = "pw_barrier.xml" },
	{ h = 0, color = "ffffe098", file = "cheese/biome.xml" },
	{ h = 0, color = "ffffdf94", file = "orbroom_sky.xml" },
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

-- remove bottom part of the lava lake pit (replaced with collapsed mines)
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

-- move gourd room from the cloudscape (chunk Y=-6656) to the lake (chunk Y=0)
for file in nxml.edit_file("data/biome_impl/spliced/gourd_room.xml") do
	local ps = file:first_of("mBufferedPixelScenes")
	if not ps then break end

	local offset = 6656
	for scene in ps:each_of("PixelScene") do
		local y = tonumber(scene:get("pos_y"))
		if y then
			scene:set("pos_y", y + offset)
		end
	end
end

-- the hiisi shop & hourglass can now only generate on the right
utils.modifile(
	"data/scripts/biomes/snowcastle_cavern.lua",
	[[local is_right = ]],
	[[local is_right = true --]]
)

utils.modifile(
	"data/scripts/buildings/teleport_hourglass_return.lua",
	[[ProceduralRandom(0,0) > 0.5]],
	[[true]]
)

-- fast travel room needs to be unlocked per-run
-- (the boss kill script already adds both game flag and persistent flag)
utils.modifile(
	"data/scripts/buildings/teleroom.lua",
	[[HasFlagPersistent( "miniboss_fish" )]],
	[[GameHasFlagRun("miniboss_fish")]]
)
-- TODO: teleroom is temporarily removed, i dont feel like fixing all the portals for now
--	     color on biome map = #5f8fab

-- robot egg is moved to be a side path to the hell, accessible with a quest
imutil.ImageOverlay("data/biome_impl/robot_egg.png", "mods/noita.hardmod/files/modules/biome_map/gfx/robot_egg.png")

-- pyramid orb is moved to top-right cloudscape
imutil.ImageReplace("data/biome_impl/pyramid/top_visual.png", "mods/noita.hardmod/files/modules/biome_map/gfx/pyramid_top_visual.png")
utils.modifile(
	"data/scripts/biomes/pyramid_top.lua",
	[[EntityLoad( "data/entities/items/orbs/orb_01.xml", x, y )]],
	[[--]]
)

ModMagicNumbersFileAdd("mods/noita.hardmod/files/modules/biome_map/magic_numbers.xml")
ModMaterialsFileAdd("mods/noita.hardmod/files/modules/biome_map/materials.xml")

function hooks.player_spawned(pid, is_run_start)
	if is_run_start then
		EntitySetDamageFromMaterial(pid, "hardmod_cursed_liquid", 0.004)
		EntitySetDamageFromMaterial(pid, "hardmod_cursed_liquid_static", 0.004)
	end

	local path = MagicNumbersGetValue("BIOME_MAP")
	if path == biome_map_path then
		dofile_once("mods/noita.hardmod/files/modules/biome_map/orbs.lua")
	else
		local x, y = EntityGetTransform(pid)
		utils.SpawnTablet(
			x, y, "Noita Hard Mod: Errors Occurred!!!",
			"Mod compatibility error: The 'Biome Map Changes' module is enabled, but we failed to\n"
			.."apply our worldgen changes!!! Another mod overwrote the biome map file to:\n"
			.."- '"..path.."'\n \n"
			.."Please move Hard Mod to start before this mod."
		)
	end
end

return hooks
