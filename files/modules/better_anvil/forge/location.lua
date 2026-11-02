---@alias Range [number, number]

SetRandomSeed(1464, 5976)

local left_x, right_x = -1917, 1464
local top_y, bottom_y = 5120, 5976

local forge_spawn_locations = {
	{ name = "topleft", x = left_x, y = top_y },
	{ name = "bottomleft", x = left_x, y = bottom_y },
	{ name = "topright", x = right_x, y = top_y },

	{
		name = "topmiddle",
		x = Random() >= .5 and Random(-950, -285) or Random(530, right_x),
		y = top_y
	},
	{ name = "bottommiddle", x = Random(-950, 437), y = bottom_y },
}

local location = forge_spawn_locations[Random(1, #forge_spawn_locations)]

print("Spawning forge at "..location.name)

return location

-- local w4 = (right_x - left_x) / 4
-- local h2 = (bottom_y - top_y) / 2

-- ---@type {x:Range,y:Range}[]
-- local blacklisted_areas = {
--   -- HM entrance
--   { x = { -185, 460 }, y = { top_y, 5500 } },
--   -- original anvil
--   { x = { 1120, right_x }, y = { 5706, bottom_y } },
-- }

-- local forge_spawn_x = {
--   left = { left_x, left_x + w4 },
--   middle = { left_x + w4, right_x - w4 },
--   right = { right_x - w4, right_x },
-- }

-- local forge_spawn_y = {
--   top = { top_y, top_y + h2 },
--   bottom = { bottom_y - h2, bottom_y },
-- }

-- ---@type {name:string,x:Range,y:Range}[]
-- local locations = {}

-- for xdir,x in pairs(forge_spawn_x) do
--   for ydir,y in pairs(forge_spawn_y) do
--     table.insert(locations, {
--       name = ydir..xdir, x = x, y = y
--     })
--   end
-- end

-- local function pick_location(try)
--   SetRandomSeed(1464, 5976 + (try or 0))
--   local area = locations[Random(1, #locations)]
--   local x = Random(area.x[1], area.x[2])
--   local y = Random(area.y[1], area.y[2])

--   for _,region in pairs(blacklisted_areas) do
--     if
--       x >= region.x[1] and x <= region.x[2]
--       and y >= region.y[1] and y <= region.y[2]
--     then
--       return pick_location((try or 0) + 1)
--     end
--   end

--   return { name = area.name, x = x, y = y }
-- end

-- local location = pick_location()
-- print("Spawning forge at "..location.name)

-- return location
