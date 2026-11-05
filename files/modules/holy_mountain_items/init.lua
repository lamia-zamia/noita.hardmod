local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

for file in nxml.edit_file("data/entities/items/pickup/spell_refresh.xml") do
	local item = file:first_of("ItemComponent")
	if item then item:set("auto_pickup", false) end
end

for file in nxml.edit_file("data/entities/items/pickup/heart_fullhp.xml") do
	local item = file:first_of("ItemComponent")
	if item then item:set("auto_pickup", false) end
end

ModLuaFileAppend(
  "data/scripts/biomes/temple_altar.lua",
  "mods/noita.hardmod/files/modules/holy_mountain_items/altar_append.lua"
)

return {}
