local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

function damage_about_to_be_received(damage, _x, _y, entity_who_caused, critical_hit_chance)
	local boss = GetUpdatedEntityID()
	local x, y = EntityGetTransform(boss)

	if entity_who_caused ~= nil then
		dofile_once("data/scripts/lib/utilities.lua")
		local px, py = EntityGetTransform(entity_who_caused)
		if not px or not py then
			return damage, critical_hit_chance
		end

		local dist = get_distance(x, y, px, py)
		local outer_radius = utils.GetInternalInt(boss, "boss_cage_aura_outer_radius") or 500
		if dist > outer_radius * 0.9 then
    		return 0, 0
		end
	end
	return damage, critical_hit_chance
end
