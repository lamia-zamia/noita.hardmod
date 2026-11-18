--ad2e00 spear statue

RegisterSpawnFunction(0xff04d1a3, "hardmod_spawn_area_checks")
RegisterSpawnFunction(0xffad2e00, "hardmod_spawn_spear_statue")
RegisterSpawnFunction(0xffda304b, "hardmod_spawn_collapse_crystal")

function hardmod_spawn_area_checks(x, y)
	local mat_check_manager = EntityLoad("mods/noita.hardmod/files/modules/holy_mountain_rework/leak_detector 2.0.xml", x, y)
	local tbrick1 = CellFactory_GetType("templebrick_noedge_static")
	local tbrick2 = CellFactory_GetType("templebrick_static")

	local function place_mat_checker(ax, ay, aw, ah)
		local comp = EntityAddComponent2(mat_check_manager, "MaterialAreaCheckerComponent", {
			material = tbrick1,
			material2 = tbrick2,
			kill_after_message = true,
			look_for_failure = true
		})

		--min x, min y, max x, max y
		ComponentSetValue2(comp, "area_aabb", ax, ay, ax+aw, ay+ah)
	end
	place_mat_checker(-16, -90, 120, 1)
	place_mat_checker(120-16, -90, 1, 24+90)
	place_mat_checker(-16, 154, 114, 1)
end


function hardmod_spawn_spear_statue(x, y)
	EntityLoad("data/entities/props/temple_statue_01.xml", x, y)
end

function hardmod_spawn_collapse_crystal(x, y)
	EntityLoad( "mods/noita.hardmod/files/modules/holy_mountain_rework/crystal/crystal.xml", x, y)
	EntityLoad( "mods/noita.hardmod/files/modules/holy_mountain_rework/crystal/crystal_attractor.xml", x, y)
	EntityLoad( "mods/noita.hardmod/files/modules/holy_mountain_rework/crystal/crystal_base.xml", x, y+5)
end
