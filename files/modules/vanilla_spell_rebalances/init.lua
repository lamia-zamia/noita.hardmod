local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

local mists = { "slime", "alcohol", "blood", "radioactive" }
for _,mist in pairs(mists) do
  for file in nxml.edit_file("data/entities/projectiles/deck/mist_"..mist..".xml") do
    local comp = file:first_of("ProjectileComponent")
    if comp then
      comp:set("lifetime", 200)
      comp:set("damage_every_x_frames", 30)
      comp:set("collide_with_world", true)
    end
  end
end

for file in nxml.edit_file("data/entities/projectiles/deck/base_field.xml") do
  local proj = file:first_of("ProjectileComponent")
  if proj then
    proj:set("collide_with_world", true)
    proj:set("damage_every_x_frames", 30)
  end

  local lifetime = file:first_of("LifetimeComponent")
  if lifetime then
    lifetime:set("lifetime", 900)
  end
end

for file in nxml.edit_file("data/entities/misc/area_damage.xml") do
	local comp = file:first_of("AreaDamageComponent")
	if comp then
		comp:set("damage_per_frame", 0.07)
		comp:set("circle_radius", 11)
	end
end

for file in nxml.edit_file("data/entities/misc/homing.xml") do
	local comp = file:first_of("HomingComponent")
	if comp then
		comp:set("homing_targeting_coeff", 200)
		comp:set("homing_velocity_multiplier", 0.7)
		comp:set("detect_distance", 120)
	end
end

ModLuaFileAppend("data/scripts/biomes/temple_altar.lua", "mods/noita.hardmod/files/modules/vanilla_spell_rebalances/appends/temple_altar.lua")

return {}
