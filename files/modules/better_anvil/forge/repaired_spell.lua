local level = 5
local extra_level = 5
local max_extras = 2

return function (x, y)
  SetRandomSeed(x, y)
  local extras = Random(1, max_extras)
  
  SpawnActionItem(x, y, level)

  x = x - 10 * (extras / 2)

  for _=1,extras do
    SpawnActionItem(x, y - 5, extra_level)
    x = x + 10
  end
end
