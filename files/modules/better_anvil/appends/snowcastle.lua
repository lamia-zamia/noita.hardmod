local forge_location = dofile_once("mods/noita.hardmod/files/modules/better_anvil/forge/location.lua")

RegisterSpawnFunction(0xff4cac00, "spawn_forge_tablet")

function spawn_forge_tablet(x, y)
  local book = EntityLoad("mods/noita.hardmod/files/modules/better_anvil/forge/book_moved.xml", x, y)

  local direction = GameTextGet("$hardmod_anvil_dir_" .. forge_location.name)
  local description = GameTextGet("$hardmod_anvil_book_moved_desc", direction)

  local comps = EntityGetComponent(book, "ItemComponent")
  if comps then
    for _,comp in pairs(comps) do
      ComponentSetValue2(comp, "ui_description", description)
    end
  end

  EntityLoad("data/entities/props/physics_propane_tank.xml", x + 20, y)
end
