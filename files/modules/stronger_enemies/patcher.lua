local function patch_enemy(enemy, patch)
	if patch.ng then enemy.ngpluslevel = patch.ng end
	if patch.prob then enemy.prob = patch.prob end
end

function PatchEnemies(tbl, patches)
  for _,enemy in pairs(tbl) do
    if type(enemy) == "table" and enemy.entity then
      local patch = patches[enemy.entity]
      if patch then patch_enemy(enemy, patch) end
    end
  end
end

function PatchEnemiesWithGroups(tbl, patches)
	for _,enemy in pairs(tbl) do
		if type(enemy) == "table" and enemy.entities then
			local patch = nil
			for _,entry in pairs(enemy.entities) do
				local entity = type(entry) == "table" and entry.entity or entry
				if patches[entity] then
					apply = patches[entity]
					break
				end
			end

			if patch then
				patch_enemy(enemy, patch)
			end
		end
	end
end

function AddEnemies(tbl, spawns)
  for _,enemy in pairs(spawns) do
	enemy.min_count = enemy.min_count or 1
	enemy.max_count = enemy.max_count or 1

    table.insert(tbl, enemy)
  end
end
