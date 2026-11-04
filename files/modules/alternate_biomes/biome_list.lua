local root = "mods/noita.hardmod/files/modules/alternate_biomes/"

-- `name` and `script` are important for other modules extending vanilla biomes
-- or relying on UI name to identify them

local list = {
	coalmine = {
		{
			name = "$hardmod_biomename_infested_mines",
			biome = "fungal_mines",
			script = root.."biomes/fungal_mines.lua",
			weight = 100
		},
	},
	excavationsite = {
		{
			name = "$hardmod_biomename_sand_pits",
			biome = "sand_pits",
			script = root.."biomes/sand_pits.lua",
			weight = 100
		}
	}
}

local function weighted_choice(options)
	local total = 1.0
	for _, o in ipairs(options) do
		local w = o.weight or 0
		if w > 0 then total = total + w end
	end
	local r = Randomf(0, total)
	if r <= 1.0 then return nil end
	local acc = 1.0
	for _, o in ipairs(options) do
		local w = o.weight or 0
		if w > 0 then
			acc = acc + w
			if r <= acc then return o.biome end
		end
	end
	return nil
end

local function get_replacements()
	local i = 0
	local replacements = {}
	for source_biome, options in pairs(list) do
		i = i + 1
		SetRandomSeed(i, i)
		local target = weighted_choice(options)
		if target then
			replacements[source_biome] = target
		end
	end

	return replacements
end

return {
	list = list,
	get_replacements = get_replacements
}
