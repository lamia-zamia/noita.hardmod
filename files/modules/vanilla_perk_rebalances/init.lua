local hooks = {}
local dir = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/"

local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local imutil = dofile_once("mods/noita.hardmod/lib/image_utils.lua") ---@type image_utils

local lootlib = dofile_once("mods/noita.hardmod/lib/lootlib.lua") ---@type lootlib
lootlib.add_patch_script(dir.."scripts/lootlib_patch.lua")

ModMaterialsFileAdd(dir.."materials.xml")

local orbrooms = { "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11" }
for _,num in pairs(orbrooms) do
	ModLuaFileAppend("data/scripts/biomes/orbrooms/orbroom_"..num..".lua", dir.."scripts/appends/orbroom.lua")
end

imutil.ImageOverlay("data/biome_impl/orbroom_visual.png", dir.."gfx/orbroom_visual.png")

-- xml modifications as separate functions for better readability

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
			script_source_file=dir.."scripts/appends/altar_tablet_magic.lua",
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
			script_source_file = dir.."scripts/perks/wand_experimenter/init.lua"
		})
	end

	ModLuaFileAppend("data/scripts/perks/wand_experimenter.lua", dir.."scripts/perks/wand_experimenter/append.lua")
end


--[[ Spells Materialised ]]
--#region
local spell_card_append_targets = {
	["data/entities/misc/custom_cards/action.xml"] = true,
	["data/entities/base_custom_card.xml"] = true,
}
--#endregion


--[[ Gold Is Dust ]]
--#region
--if ModSettingGet("GID.vanilla_bloody then") then ModMaterialsFileAdd(root.."materials/materials_extra_bloody.xml") end
if ModIsEnabled("prospector-perk") then
	ModLuaFileAppend("mods/prospector-perk/files/perk/prospector.lua", dir.."gold_is_dust/append_prospector.lua")
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
	script_source_file = dir.."gold_is_dust/nugget_expire.lua",
	script_item_picked_up = dir.."gold_is_dust/nugget_pickup.lua",
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
			script_source_file=dir.."gold_is_dust/collect_gold.lua"
		})
	}))
end
--#endregion

local update_amp_item_scr = dir.."scripts/perks/update_amplified_item.lua"
local amplified_items_lua_comp = nxml.new_element("LuaComponent", {
	_tags = "enabled_in_hand",
	--script_source_file = update_amp_item_scr,
	--execute_every_n_frame = "300",
	execute_every_n_frame = "-1",
	script_enabled_changed = update_amp_item_scr,
	--script_item_picked_up = update_amp_item_scr,
})
local ase_items = {
	"data/entities/items/pickup/sun/sunseed.xml",
	"data/entities/items/pickup/sun/sunstone.xml",
}
local ase_entity = nxml.parse_file("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/perks/all_seeing_eye.xml")
for _,path in ipairs(ase_items) do
	for xml in nxml.edit_file(path) do
		for game_effect in xml:each_of("GameEffectComponent") do
			if game_effect.attr.effect == "REMOVE_FOG_OF_WAR" then
				xml:remove_child(game_effect)
				xml:add_child(ase_entity)
			end
		end

		xml:add_child(amplified_items_lua_comp)
	end
end

local amplified_item_targets = {
	"data/entities/items/pickup/brimstone.xml",
	"data/entities/items/pickup/waterstone.xml",
	"data/entities/items/pickup/thunderstone.xml",
	"mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/items/cheese.xml",
	"data/entities/items/pickup/sun/sunseed.xml",
	"data/entities/items/pickup/sun/sunstone.xml",
	--"",
}
for _,path in ipairs(amplified_item_targets) do
	for xml in nxml.edit_file(path) do
		xml:add_child(amplified_items_lua_comp)
	end
end



ModLuaFileAppend("data/scripts/items/__drop_money.lua", dir.."scripts/append_gold_drops.lua")


hooks.mod_init = function()
	modify_wandstone()
	modify_mountain_altar()
	modify_xray()
	modify_wand_experimenter()
end

hooks.mod_post_init = function()
	ModLuaFileAppend("data/scripts/gun/gun_extra_modifiers.lua", dir.."scripts/appends/gun_extra_modifiers.lua")
	ModLuaFileAppend("data/scripts/item_spawnlists.lua", dir.."scripts/appends/item_spawnlists.lua")
	ModLuaFileAppend("data/scripts/biomes/snowcastle_hourglass_chamber.lua", dir.."scripts/appends/hourglass_chamber.lua")
	-- ModLuaFileAppend( "data/scripts/gun/gun.lua", dir.."/scripts/appends/gun.lua" )
	-- ModLuaFileAppend( "data/scripts/gun/procedural/gun_procedural.lua", dir.."/scripts/appends/gun_procedural.lua" )

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
				script_source_file = dir.."spells_materialised/spell_append.lua",
				remove_after_executed = "1"
			}))
		end
	end

	for xml in nxml.edit_file("data/entities/player_base.xml") do
		for child in xml:each_of("Entity") do
			if child.attr.name == "arm_r" then
				child:add_child(nxml.new_element("LuaComponent", {
					script_shot = dir.."spells_materialised/shoot_spell.lua"
				}))
			end
		end
	end
end


-- Apotheosis fails to do nil checks for its target components, completely fails to load as a result, this disables the relevant code
local f1,t1,f2,t2 =
	[[do
  local content = ModTextFileGetContent("data/entities/items/pickup/sun/sunseed.xml")]],
	[[if false then
  local content = ModTextFileGetContent("data/entities/items/pickup/sun/sunseed.xml")]],
	[[do
	local content = ModTextFileGetContent("data/entities/items/pickup/sun/sunstone.xml")]],
	[[if false then
	local content = ModTextFileGetContent("data/entities/items/pickup/sun/sunstone.xml")]]

if ModIsEnabled("Apotheosis") then
	utils.patchifile("mods/Apotheosis/files/scripts/mod_compatibility/vanilla_appends.lua", {
		{
			from = f1,
			to = t1,
		},
		{
			from = f2,
			to = t2,
		},
	})
end --We can remove this if Apotheosis 1.4.0 ever releases.

return hooks