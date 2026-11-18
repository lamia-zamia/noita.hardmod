local list = spawnlists.potion_spawnlist

local rnd_min = list.rnd_max + 1
local rnd_max = rnd_min + 1
list.rnd_max = rnd_max

table.insert(list.spawns, {
  value_min = rnd_min,
  value_max = rnd_max,
  offset_y = -2,
  load_entity = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/items/cheese.xml"
})
