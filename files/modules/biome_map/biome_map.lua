-- TODO: random side biomes and stuff
-- also i'd very much like to implement the upside down world thing

-- TODO: setting to not alter worldgen too much and instead have minimal changes
-- (such as no top-right gold or the path between ancient lab and fungal)
-- minimal changes can be done dynamically by scanning for patterns

local biomemap_filepath = "mods/noita.hardmod/files/modules/biome_map/gfx/biome_map_altered.png"
local biomemap_width = 72
local biomemap_height = 48
if ModIsEnabled("Apotheosis") then
	biomemap_width = 102
	biomemap_height = 48
	biomemap_filepath = "mods/noita.hardmod/files/modules/biome_map/cross_mod_compat/biome_map_apotheosis_merged.png"
end

BiomeMapSetSize(biomemap_width, biomemap_height)
BiomeMapLoadImage(0, 0, biomemap_filepath)

