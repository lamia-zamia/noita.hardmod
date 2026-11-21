dofile_once("data/scripts/perks/perk.lua")

function death()
	local x, y = EntityGetTransform(GetUpdatedEntityID())
	perk_spawn(x, y, "HARDMOD_ALEPH", true)
end
