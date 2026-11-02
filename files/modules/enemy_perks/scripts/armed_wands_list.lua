SetRandomSeed(-249, -84)



local wands = {
	{
		weight = 10,
		drop_probability = 0,
		stats = {},
		formula = {
			"LIGHT_BULLET_TRIGGER",
			"BOMB",
		},
	}
}


for _,path in ipairs(ModLuaFileGetAppends("mods/noita.hardmod/files/modules/enemy_perks/scripts/armed_wands_list.lua")) do
	dofile_once(path)(wands)
end


for _,wand in ipairs(wands) do
	wand.weight = wand.weight or 10
	wand.drop_probability = wand.drop_probability or 0

	wand.stats = wand.stats or {}
	local stats = wand.stats
	stats.shuffle = stats.shuffle or false
	stats.spells_per_cast = stats.spells_per_cast or 1
	stats.cd = stats.cd or Random(8, 19)
	stats.rt = stats.rt or Random(28, 44)
	stats.max_mana = stats.max_mana or Random(240, 563)
	stats.mana_charge_speed = stats.mana_charge_speed or Random(34, 110)
	stats.capacity = stats.capacity or math.max(1, math.min(#wand.formula + math.ceil(Random(0, #wand.formula*.5)), 26))
end

return wands