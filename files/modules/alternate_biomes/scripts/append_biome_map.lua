local alt_biomes = dofile_once("mods/noita.hardmod/files/modules/alternate_biomes/biome_list.lua")

SetRandomSeed(-149,4297)

local function swap_rb(c)
	return 0xFF000000
		+ bit.lshift(bit.band(c, 0xFF), 16)
		+ bit.lshift(bit.band(bit.rshift(c, 8), 0xFF), 8)
		+ bit.band(bit.rshift(c, 16), 0xFF)
end

local pixel_lookup = {}
for _,alt_biome in ipairs(alt_biomes) do
	if Random() <= alt_biome.probability then
		--replacement.replace_with = swap_rb(replacement.replace_with)
		pixel_lookup[swap_rb(alt_biome.replaces_colour)] = alt_biome
	end
end

local w,h = BiomeMapGetSize()
for x = 1, w do
	for y = 1, h do
		local pixel = BiomeMapGetPixel(x, y) % 2^32
		if pixel_lookup[pixel] then
			BiomeMapSetPixel(x, y, pixel_lookup[pixel].colour_id)
		end
	end
end