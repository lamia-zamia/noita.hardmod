local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local basin_mats = {
	{
		weight = 15,
		material = "air",
	},
	{
		weight = 5,
		material = "lava",
	},
	{
		weight = 4,
		material = "magic_liquid_polymorph",
	},
	{
		weight = 4,
		material = "magic_liquid_random_polymorph",
	},
	{
		weight = 3,
		material = "radioactive_liquid",
	},
	{
		weight = 3,
		material = "oil",
	},
	{
		weight = 2,
		material = "water",
	},
	{
		weight = 2,
		material = "blood",
	},
}

local evil_hms = {
	{ 4400, 5100 },
	{ 6000, 6700 },
	{ 8000, 8700 },
}

local function get_material(x, y)

	SetRandomSeed(666, 666)
	local evil = Random(1, 16)
	if evil <= #evil_hms then
		local hm = evil_hms[evil]
		if y >= hm[1] and y <= hm[2] then
			return "lava"
		end
	end

	SetRandomSeed(x, y)
	return utils.RandomFromTable(basin_mats).material
end

function spawn_altar_top(x, y, is_solid)
	LoadBackgroundSprite("data/biome_impl/temple/wall_background.png", x-1, y - 30, 35)

	local material = get_material(x, y)

	local base = "mods/noita.hardmod/files/modules/trappier_traps/portal_basin/"
	if material == "air" then base = "data/biome_impl/temple/" end

	local colors = base.."altar_top.png"
	if y > 12000 then colors = base.."altar_top_ending.png" end
	LoadPixelScene(
		colors,	"data/biome_impl/temple/altar_top_visual.png",
		x, y-40, "", true, false, {["ff0000ff"] = material,}
	)

	if is_solid then
		LoadPixelScene("data/biome_impl/temple/solid.png", "", x, y-40+300, "", true)
	end
end
