dofile("data/scripts/lib/utilities.lua")

local entity_id = GetUpdatedEntityID()
local x, y, r, s1, s2 = EntityGetTransform(entity_id)

local camera_x, camera_y, camera_w, camera_h = GameGetCameraBounds()

local camera_center_x = camera_x + (camera_w / 2)
local camera_center_y = camera_y + (camera_h / 2)

local direction_x = x - camera_center_x
local direction_y = y - camera_center_y
local len = math.sqrt(direction_x * direction_x + direction_y * direction_y)

direction_x = direction_x / len
direction_y = direction_y / len

local edge_x = camera_center_x + direction_x * camera_w / 2
local edge_y = camera_center_y + direction_y * camera_h / 2

local distance_from_edge = math.sqrt((edge_x - x) * (edge_x - x) + (edge_y - y) * (edge_y - y))
if x > camera_x and x < camera_x + camera_w and y > camera_y and y < camera_y + camera_h then
	teleport_timer = nil
	return
end

SetRandomSeed(camera_x + x, camera_y + y)

teleport_timer = teleport_timer or Random(360, 7200)

if distance_from_edge > 100 then
	if teleport_timer <= 0 then
		teleport_timer = Random(360, 7200)
		local tries = 0
		local max_tries = 100
		local max_distance_from_edge = 10
		local valid = false
		local new_x, new_y = 0, 0

		while tries < max_tries and not valid do
			local dx = Random(0, 1)
			if dx == 0 then dx = -1 end

			new_x = camera_center_x + (camera_w / 2 + max_distance_from_edge) * dx
			new_y = Random(camera_y, camera_y + camera_h)

			if not RaytracePlatforms(new_x + 2, new_y + 2, new_x - 2, new_y - 2) then valid = true end

			local hit, hit_x, hit_y = RaytracePlatforms(new_x, new_y, new_x, new_y + 1000)
			if hit then new_y = hit_y - 3 end

			tries = tries + 1
		end

		if valid then EntityApplyTransform(entity_id, new_x, new_y) end
	else
		teleport_timer = teleport_timer - 1
	end
end
