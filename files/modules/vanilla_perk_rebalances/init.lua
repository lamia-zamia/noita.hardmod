local hooks = {}
local root = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/"

local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local imutil = dofile_once("mods/noita.hardmod/lib/image_utils.lua") ---@type image_utils

local lootlib = dofile_once("mods/noita.hardmod/lib/lootlib.lua") ---@type lootlib
lootlib.add_patch_script(root.."scripts/lootlib_patch.lua")

ModMaterialsFileAdd(root.."materials.xml")

local orbrooms = { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11" }
for _,num in pairs(orbrooms) do
	ModLuaFileAppend("data/scripts/biomes/orbrooms/orbroom_"..num..".lua", root.."scripts/appends/orbroom.lua")
end

imutil.ImageOverlay("data/biome_impl/orbroom_visual.png", root.."gfx/orbroom_visual.png")

-- xml modifications as separate functions for better readability
local function modify_master_of_blinding()
	for xml in nxml.edit_file("data/entities/animals/wizard_dark.xml") do
		xml:add_child(nxml.new_element("LuaComponent", {
			script_source_file=root.."scripts/wizard_dark_ase_scan.lua",
			execute_every_n_frame="2",
		}))
	end
end

local function modify_wandstone()
	for xml in nxml.edit_file("data/entities/items/pickup/wandstone.xml") do
		local tags = xml.attr.tags
		if #tags == 0 then xml.attr.tags = "hardmod_wandstone"
		else xml.attr.tags = tags .. ",hardmod_wandstone" end
	end
end

local function modify_mountain_altar()
	for xml in nxml.edit_file("data/entities/animals/boss_centipede/ending/ending_sampo_spot_mountain.xml") do
		xml:add_child(nxml.new_element("LuaComponent", {
			script_source_file=root.."scripts/appends/altar_tablet_magic.lua",
			execute_every_n_frame="240",
		}))
	end
end

local function modify_xray()
	local path = "data/entities/projectiles/deck/xray.xml"
	local xml = nxml.parse( ModTextFileGetContent( path ) )
	local proj_comp = xml:first_of("ProjectileComponent")
	if proj_comp then
		proj_comp:set( "lifetime", 30 )
	end
	ModTextFileSetContent( path, tostring(xml) )
end

local function modify_wand_experimenter()
	for file in nxml.edit_file("data/entities/base_wand.xml") do
		file:create_child("LuaComponent", {
			_enabled = true,
			execute_every_n_frame = 2,
			remove_after_executed = true,
			script_source_file = root.."scripts/perks/wand_experimenter/init.lua"
		})
	end

	ModLuaFileAppend("data/scripts/perks/wand_experimenter.lua", root.."scripts/perks/wand_experimenter/append.lua")
end


--[[ Spells Materialised ]]

local spell_card_append_targets = {
	["data/entities/misc/custom_cards/action.xml"] = true,
	["data/entities/base_custom_card.xml"] = true,
}



--[[ Gold Is Dust ]]
--if ModSettingGet("GID.vanilla_bloody then") then ModMaterialsFileAdd(root.."materials/materials_extra_bloody.xml") end
if ModIsEnabled("prospector-perk") then
	ModLuaFileAppend("mods/prospector-perk/files/perk/prospector.lua", root.."gold_is_dust/append_prospector.lua")
end
local list_of_nuggets = {
	"data/entities/items/pickup/goldnugget.xml",
	"data/entities/items/pickup/goldnugget_10.xml",
	"data/entities/items/pickup/goldnugget_50.xml",
	"data/entities/items/pickup/goldnugget_200.xml",
	"data/entities/items/pickup/goldnugget_1000.xml",
	"data/entities/items/pickup/goldnugget_10000.xml",
	"data/entities/items/pickup/goldnugget_200000.xml",
	"data/entities/items/pickup/goldnugget_x.xml",
}
local luacomp = nxml.new_element("LuaComponent", {
	script_source_file = root.."gold_is_dust/nugget_expire.lua",
	script_item_picked_up = root.."gold_is_dust/nugget_pickup.lua",
	execute_every_n_frame = "-1",
	execute_on_removed = "1"
})
for _, path in ipairs(list_of_nuggets) do
	for xml in nxml.edit_file(path) do xml:add_child(luacomp) end
end
for xml in nxml.edit_file("data/entities/player_base.xml") do
	xml:add_child(nxml.new_element("Entity", {name="hardmod.gold_collect"}, {
		nxml.new_element("InheritTransformComponent", {}, {
			nxml.new_element("Transform", {
				["position.y"]="6"
			})
		}),
		nxml.new_element("MaterialSuckerComponent", {
			material_type = "1",
			suck_tag = "[hardmod.gold]",
			barrel_size="100",
			num_cells_sucked_per_frame="50",
			["randomized_position.min_x"]="-5",
			["randomized_position.max_x"]="5",
			["randomized_position.min_y"]="-4",
			["randomized_position.max_y"]="-1",
		}),
		nxml.new_element("MaterialInventoryComponent"),
		nxml.new_element("LuaComponent", {
			script_source_file=root.."gold_is_dust/collect_gold.lua"
		})
	}))
end



utils.modifile("data/scripts/items/gold_pickup.lua", [[hp_value = hp_value * 0.5]], [[hp_value = money * 0.004]])


hooks.mod_init = function()
	modify_master_of_blinding()
	modify_wandstone()
	modify_mountain_altar()
	modify_xray()
	modify_wand_experimenter()
end

hooks.mod_post_init = function()
	ModLuaFileAppend("data/scripts/gun/gun_extra_modifiers.lua", root.."scripts/appends/gun_extra_modifiers.lua")
	ModLuaFileAppend("data/scripts/item_spawnlists.lua", root.."scripts/appends/item_spawnlists.lua")
	ModLuaFileAppend("data/scripts/biomes/snowcastle_hourglass_chamber.lua", root.."scripts/appends/hourglass_chamber.lua")

	-- ModLuaFileAppend("data/scripts/perks/perk.lua", root.."scripts/appends/perk.lua")
	-- ModLuaFileAppend("data/scripts/magic/altar_tablet_magic.lua", root.."scripts/appends/altar_tablet_magic.lua")

	dofile_once("data/scripts/gun/gun_actions.lua")
	---@diagnostic disable-next-line:undefined-global
	for _,action in pairs(actions) do
		if action.custom_xml_file then
			spell_card_append_targets[action.custom_xml_file] = true
		end
	end

	for path,_ in pairs(spell_card_append_targets) do
		for xml in nxml.edit_file(path) do
			if xml:first_of("AbilityComponent") then break end

			xml:add_child(nxml.new_element("LuaComponent", {
				_tags = "enabled_in_world,enabled_in_inventory,enabled_in_world",
				script_source_file = root.."spells_materialised/spell_append.lua",
				remove_after_executed = "1"
			}))
		end
	end

	for xml in nxml.edit_file("data/entities/player_base.xml") do
		for child in xml:each_of("Entity") do
			if child.attr.name == "arm_r" then
				child:add_child(nxml.new_element("LuaComponent", {
					script_shot = root.."spells_materialised/shoot_spell.lua"
				}))
			end
		end
	end
end

return hooks
