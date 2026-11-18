function death(damage_type_bit_field, damage_message, entity_thats_responsible, drop_items)
	local x, y = EntityGetTransform(GetUpdatedEntityID())
	EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/kamikaze_explosion.xml", x, y)
end
