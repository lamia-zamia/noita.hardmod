
-- wand ghost does not take damage from its own attacks
function damage_about_to_be_received(damage, x, y, entity_thats_responsible, critical_hit_chance)
	if entity_thats_responsible == GetUpdatedEntityID() then
    	return 0, 0
    else
    	return damage, critical_hit_chance
    end
end
