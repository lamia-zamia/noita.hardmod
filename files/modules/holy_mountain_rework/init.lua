local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local img = dofile_once("mods/noita.hardmod/lib/image_utils.lua")

local hooks = {} ---@hooks
local path = "mods/noita.hardmod/files/modules/holy_mountain_rework/"
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

ModMaterialsFileAdd(path.."materials.xml")

local move_targets = {
	["data/biome_impl/temple/altar_snowcave_capsule.png"] = true,
	["data/biome_impl/temple/altar_snowcastle_capsule.png"] = true,
	["data/biome_impl/temple/altar_vault_capsule.png"] = true,
}
for xml in nxml.edit_file("data/biome/_pixel_scenes.xml") do
	for child in xml:first_of("mBufferedPixelScenes"):each_child() do
		if move_targets[child.attr.material_filename] then
			child.attr.pos_x = child.attr.pos_x - 44
		end
	end
end


local visual_references = {
	"data/scripts/biomes/temple_altar_right_empty.lua",
	"data/scripts/biomes/temple_altar_right_snowcastle_empty.lua",
	"data/scripts/biomes/temple_altar_right_snowcastle.lua",
	"data/scripts/biomes/temple_altar_right_snowcave_empty.lua",
	"data/scripts/biomes/temple_altar_right_snowcave.lua",
	"data/scripts/biomes/temple_altar_right.lua",
}

local visual_path = path.."images/visual.png"
local bg_path = path.."images/background.png"
local append_path = path.."append_right_altar.lua"
for _,file in ipairs(visual_references) do
	utils.modifile(file, [[data/biome_impl/temple/altar_right_visual.png]], visual_path)
	utils.modifile(file, [[data/biome_impl/temple/altar_right_background.png]], bg_path)
	ModLuaFileAppend(file, append_path)
end
img.ImageOverlay("data/biome_impl/temple/altar_right.png", path.."images/material.png", 0, 8)
img.ImageOverlay("data/biome_impl/temple/altar_right_snowcastle.png", path.."images/material_flat_exit.png", 0, 8)

utils.modifile("data/scripts/perks/perk.lua",
		[[if( Random( 1, 100 ) <= perk_destroy_chance ) then]],
		[[if( Random( 1, 100 ) <= perk_destroy_chance ) then dofile("mods/noita.hardmod/files/modules/holy_mountain_rework/perk_disappear_hook.lua")(pos_x, pos_y);]]
)
ModLuaFileAppend("data/scripts/biomes/temple_altar.lua", path.."append_altar.lua")

for _,ent in ipairs({"data/entities/buildings/physics_worm_deflector_crystal.xml", "data/entities/misc/greed_curse/greed_crystal.xml"}) do
	for xml in nxml.edit_file(ent) do
		if #xml.attr.tags == 0 then xml.attr.tags = "hm_crystal"
		else xml.attr.tags = xml.attr.tags..",hm_crystal" end
	end
end

for file in nxml.edit_file("data/entities/buildings/teleport_snowcave_buried_eye_return.xml") do
	local comp = file:first_of("TeleportComponent")
	if comp then
		comp:set("target.x", 150)
	end
end

utils.modifile(
	"data/scripts/buildings/teleport_snowcave_buried_eye_return.lua",
	[[local teleport_back_x = 190]],
	[[local teleport_back_x = 150]]
)

utils.modifile(
	"data/scripts/buildings/teleport_meditation_cube_return.lua",
	[[local teleport_back_x = 190]],
	[[local teleport_back_x = 150]]
)


-- Make HM not dug out by Lukki or Worms
local hm_diggers = {
	"data/entities/animals/worm.xml",
	"data/entities/animals/worm_big.xml",
	"data/entities/animals/worm_end.xml",
	"data/entities/animals/lukki/lukki.xml",
	"data/entities/animals/lukki/lukki_tiny.xml",
}

for _,xml_path in ipairs(hm_diggers) do
	for xml in nxml.edit_file(xml_path) do
		local cell_eater = xml:first_of("CellEaterComponent")
		if cell_eater then
			cell_eater.attr.ignored_material_tag = "[worms_lukki_ignore]"
		end
	end
end


hooks.edit_material = function(elem)
	local name = elem.attr.name
	if name == "templebrick_static" or name == "templebrick_noedge_static" then
		local tags = elem.attr.tags
		if #(tags or "") == 0 then
			elem.attr.tags = "[worms_lukki_ignore]"
		else
			elem.attr.tags = tags..",[worms_lukki_ignore]"
		end
	elseif elem.attr.name == "templebrick_static_soft" then
		elem.attr.durability = 9 --weaken the HM false-walls to be more breakable by starter-bomb spells
	end
end


for xml in nxml.edit_file("data/entities/animals/boss_centipede/ending/ending_sampo_spot_mountain.xml") do
	xml:add_child(nxml.new_element("Entity", {name = "hardmod.collapse_crystal_check"}, {
		nxml.new_element("InheritTransformComponent"),
		nxml.new_element("LuaComponent", {
			script_source_file = path.."crystal/mountain_altar_check_crystal.lua",
			execute_every_n_frame = "80"
		})
	}))
end

function hooks.player_spawned(p)
	local x,y = EntityGetTransform(p)
	--EntityLoad("mods/noita.hardmod/files/modules/holy_mountain_rework/crystal/crystal.xml", x, y)
end

return hooks