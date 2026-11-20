local tower_levels = {}

for i=1,10 do
	local biome = "data/biome/tower/solid_wall_tower_"..tostring(i)..".xml"
	tower_levels[biome] = "tower_visited_"..tostring(i)
end

function biome_entered()
	local player = GetUpdatedEntityID()
	local x, y = EntityGetTransform(player)
	local file = DebugBiomeMapGetFilename(x, y)

	if tower_levels[file] and not GameHasFlagRun(tower_levels[file]) then
		GameAddFlagRun(tower_levels[file])
		print("progress:", tower_levels[file])

		local all = true
		for _,flag in pairs(tower_levels) do
			if not GameHasFlagRun(flag) then
				all = false
				break
			end
		end

		if all then
			print("progress: ALL!")
			GameAddFlagRun("tower_visited_all")
		end
	end
end
