dofile_once("data/scripts/perks/perk.lua")

function death(damage_type_bit_field, message, attacker, drop_items)
	local x,y = EntityGetTransform(GetUpdatedEntityID())
	perk_spawn(x,y, "HARDMOD_ALEPH", true)
end