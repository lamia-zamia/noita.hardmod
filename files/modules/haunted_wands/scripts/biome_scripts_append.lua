-- 1 in x
local evil_wand_chance = 1

local orig_spawn_wands = spawn_wands
function spawn_wands(x, y)
	if ProceduralRandom(x, y, 1, evil_wand_chance) == 1 then
		EntityLoad(
			"mods/noita.hardmod/files/modules/haunted_wands/entities/evil_wand_pedestal.xml",
			x, y
		)
	end

	return orig_spawn_wands(x, y)
end
