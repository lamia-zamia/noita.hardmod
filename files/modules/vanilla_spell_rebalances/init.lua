local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml
local lootlib = dofile_once("mods/noita.hardmod/lib/lootlib.lua") ---@type lootlib
local hooks = {}

lootlib.add_patch_script("mods/noita.hardmod/files/modules/vanilla_spell_rebalances/lootlib_patch.lua")
ModMagicNumbersFileAdd("mods/noita.hardmod/files/modules/vanilla_spell_rebalances/magic_numbers.xml")

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

for file in nxml.edit_file("data/entities/projectiles/deck/buckshot_player.xml") do
	local comp = file:first_of("ProjectileComponent")
	if comp then
		comp:set("direction_random_rad", 0.18)
	end
end

local notes = {
	"kantele/kantele_a", "kantele/kantele_d",
	"kantele/kantele_dis", "kantele/kantele_e",
	"kantele/kantele_g", "ocarina/ocarina_a",
	"ocarina/ocarina_a2", "ocarina/ocarina_b",
	"ocarina/ocarina_c", "ocarina/ocarina_d",
	"ocarina/ocarina_e", "ocarina/ocarina_f",
	"ocarina/ocarina_gsharp",
}

for _,note in pairs(notes) do
	for file in nxml.edit_file("data/entities/projectiles/deck/"..note..".xml") do
		local proj = file:first_of("ProjectileComponent")
		if not proj then break end

		proj:set("on_collision_die", true)
	end
end

dofile_once("mods/noita.hardmod/files/modules/vanilla_spell_rebalances/damage.lua")

-- matter eaten't
local matter_eatent_list = {
	rock_hard_border = true,
	templebrick_static = true,
	templebrick_noedge_static = true,
}

function hooks.edit_material(mat)
	if matter_eatent_list[mat.attr.name] then
		local tags = mat.attr.tags
		tags = tags and (tags .. ",") or ""
		mat.attr.tags = tags .. "[matter_eater_ignore_list]"
	end
end

return hooks
