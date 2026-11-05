-- open ne noor

local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

for file in nxml.edit_file("data/entities/animals/boss_gate/gate_monster_a.xml") do
	file:create_child("BossHealthBarComponent", { gui = false, in_world = true })

	file:create_child("SpriteComponent", {
		_tags = "health_bar_back,ui,no_hitbox",
		image_file = "data/ui_gfx/health_slider_back_meat.png",
		offset_x = 12, offset_y = 43, emissive = 1, never_ragdollify_on_death="1",
		update_transform_rotation = false,
		has_special_scale = true,
		z_index = -9000,
	})

	file:create_child("SpriteComponent", {
		_tags = "health_bar,ui,no_hitbox",
		image_file = "data/ui_gfx/health_slider_front.png",
		offset_x = 11, offset_y = 42, emissive = 1, never_ragdollify_on_death = "1",
		update_transform_rotation = false,
		has_special_scale = true,
		z_index = -9000,
	})

	file:first_of("PhysicsImageShapeComponent"):set("material", "hardmod_gate_boss_material")
	file:first_of("CellEaterComponent"):set("ignored_material", "hardmod_gate_boss_material")

	-- damn you nolla, why does this comp not support an ignore list??
	local convert_materials = { "rock_hard", "rock_hard_border", "templerock_static", "templebrick_static", "templebrick_noedge_static", "templebrick_thick_static", "templebrickdark_static" }
	local convert_to = "rock_static_radioactive"

	local to_arr = {}
	for _,v in pairs(convert_materials) do table.insert(to_arr, convert_to) end

	file:create_child("MagicConvertMaterialComponent", {
		-- from_any_material = true,
		from_material_array = table.concat(convert_materials, ","),
        to_material_array = table.concat(to_arr, ","),
		-- to_material = "rock_static_cursed",
        loop = false, is_circle = true,
		kill_when_finished = false,
        steps_per_frame = 30,
        radius = 90,
    })
end

local gates = { "a", "b", "c", "d" }
for _,gate in pairs(gates) do
	for file in nxml.edit_file("data/entities/animals/boss_gate/gate_monster_"..gate..".xml") do
		file:create_child("Entity", {}, {
			nxml.new_element("Base", {
				file = "mods/noita.hardmod/files/modules/vanilla_bosses/entity/gate_boss_shield.xml"
			})
		})

		file:create_child("Entity", {}, {
			nxml.new_element("Base", {
				file = "mods/noita.hardmod/files/modules/vanilla_bosses/entity/gate_boss_shield_inner.xml"
			})
		})
	end
end

for file in nxml.edit_file("data/entities/buildings/wizardcave_gate_monster_spawner.xml") do
	file:first_of("CellEaterComponent"):set("ignored_material", "hardmod_gate_boss_material")
end

utils.modifile(
	"data/entities/animals/boss_wizard/death.lua",
	[[EntityLoad( "data/entities/items/pickup/wandstone.xml"]],
	[[--]]
)

utils.patchifile("data/entities/animals/boss_gate/gate_monster_death.lua", {{
	from = [[AddFlagPersistent( "miniboss_gate_monsters" )]],
	insert_after = [[
		EntityLoad("data/entities/items/pickup/wandstone.xml", pos_x, pos_y)
		EntityLoad("mods/noita.hardmod/files/modules/vanilla_bosses/entity/wandstone_emitter.xml", pos_x, pos_y)
		GamePlaySound("data/audio/Desktop/projectiles.snd", "player_projectiles/crumbling_earth/create", pos_x, pos_y)	

		for _,flag in pairs({"a","b","c","d"}) do GameRemoveFlagRun("$animal_gate_monster_"..flag.."_killed") end
	]]
}})
