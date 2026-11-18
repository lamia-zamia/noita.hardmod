local list = spawnlists.potion_spawnlist

local rnd_min = list.rnd_max + 1
local rnd_max = rnd_min + 5
list.rnd_max = rnd_max

table.insert(list.spawns, {
  value_min = rnd_min,
  value_max = rnd_max,
  offset_y = -2,
  load_entity = "data/entities/items/pickup/summon_portal_broken.xml"
})
