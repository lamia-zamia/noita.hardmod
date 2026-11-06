function death(damage_type_bit_field, message, attacker, drop_items)
	local x,y = EntityGetTransform(GetUpdatedEntityID())
	SetRandomSeed(x-219, y+191873)
	for _=1, Random(3,5) do
		EntityLoad("data/entities/animals/rat.xml", x, y)
	end
end
