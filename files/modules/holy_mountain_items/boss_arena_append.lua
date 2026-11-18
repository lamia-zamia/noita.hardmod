RegisterSpawnFunction(0xff6411ff, "hardmod_spawn_purchasable_item")
dofile_once("mods/noita.hardmod/files/modules/holy_mountain_items/shop_item/spawn.lua")

local dir = "mods/noita.hardmod/files/modules/holy_mountain_items/"

function spawn_hp(x, y)
	EntityLoad("data/entities/buildings/music_trigger_temple.xml", x-16, y)

	EntityLoad("mods/noita.hardmod/files/modules/holy_mountain_items/entities/heal_shop.xml", x-16, y)
	EntityLoad("mods/noita.hardmod/files/modules/holy_mountain_items/entities/spell_refresh_shop.xml", x+16, y)
end

local old_spawn_all_shopitems = spawn_all_shopitems
function spawn_all_shopitems(x, y, ...)
	old_spawn_all_shopitems(x, y, ...)
	dofile_once("mods/noita.hardmod/files/modules/holy_mountain_items/scripts/inject_shop_items.lua")(x, y)

	--this shouldnt be done like this but its the last day, and im tired lmao, fixthis at some point, sorry.
	LoadPixelScene(dir.."gfx/item_room.png", dir.."gfx/item_room_visual.png", x+136, y-111, dir.."gfx/item_room_bg.png")
end

--316
--54
