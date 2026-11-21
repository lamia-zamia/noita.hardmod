local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml
local lootlib = dofile_once("mods/noita.hardmod/lib/lootlib.lua") ---@type lootlib
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
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

for file in nxml.edit_file("data/entities/projectiles/darkflame.xml") do
	for comp in file:each_of("LuaComponent") do
		if comp.attr.script_source_file == "data/scripts/projectiles/darkflame.lua" then
			comp:set("execute_every_n_frame", 2)
		end
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

-- PERSONALRUNTHROWER
local personal_throwers = { "fireball_ray_enemy", "tentacle_ray_enemy", "lightning_ray_enemy" }

for _,thrower in pairs(personal_throwers) do
	for file in nxml.edit_file("data/entities/misc/"..thrower..".xml") do
		local comp = file:first_of("LifetimeComponent")
		if comp then
			-- 20s
			comp:set("lifetime", 1200)
		end
	end
end


local torches = {
	{
		path = "data/entities/misc/custom_cards/torch.xml",
		image = "data/particles/torch_fog_of_war_hole.xml",
		size = 2.5,
	},
	{
		path = "data/entities/misc/custom_cards/torch_electric.xml",
		image = "data/particles/torch_electric_fog_of_war_hole.xml",
		size = 3,
	},
}
local torch_fow_template = nxml.new_element("SpriteComponent", {
	_tags="enabled_in_hand,sound_pick_gold_sand",
	alpha="1",
	smooth_filtering="1",
	fog_of_war_hole="1",
	has_special_scale="1",
})
local torch_update_luacomp = nxml.new_element("LuaComponent", {
	_tags="enabled_in_hand",
	script_source_file="mods/noita.hardmod/files/modules/vanilla_spell_rebalances/scripts/torch_update.lua",
})
local spell_offset_luacomp = nxml.new_element("LuaComponent", {
	_tags="enabled_in_hand",
	script_enabled_changed="mods/noita.hardmod/files/modules/vanilla_spell_rebalances/scripts/set_spell_effect_offset.lua",
	execute_every_n_frame="-1",
})
local inherit_transform_comp = nxml.new_element("InheritTransformComponent", {_tags="enabled_in_hand"})
for _,torch in ipairs(torches) do
	for xml in nxml.edit_file(torch.path) do
		local torch_fow_hole = torch_fow_template
		torch_fow_hole.attr.image_file = torch.image
		torch_fow_hole.attr.special_scale_x = tostring(torch.size)
		torch_fow_hole.attr.special_scale_y = tostring(torch.size)
		xml:add_child(nxml.new_element("Entity", {name = "hardmod.torch_spotlight", tags="enabled_in_hand"}, {
			inherit_transform_comp,
			torch_fow_hole,
			torch_update_luacomp,
		}))
		xml:add_child(spell_offset_luacomp)
	end
end

utils.patchifile("data/scripts/gun/procedural/level_1_wand.lua", {
	{ from = "BLACK_HOLE_BIG", to = "SLOW_BULLET" },
	{ from = "BLACK_HOLE", to = "SLOW_BULLET" },
	{ from = "LUMINOUS_DRILL", to = "SPITTER_TIER_2" },
	{ from = "CHAINSAW", to = "SPITTER_TIER_3" },
	{ from = "FREEZE_FIELD", to = "BERSERK_FIELD" },
	{ from = "LIGHT_BULLET_TRIGGER", to = "SPITTER_TIMER" },
})

-- only one type of portal per run
utils.modifile("data/scripts/magic/ocarina.lua", "ocarina_secret_00", "kantele_secret_00")

dofile_once("mods/noita.hardmod/files/modules/vanilla_spell_rebalances/damage.lua")

-- todo: custom musical curiosit(ies)?
-- these for both kantele and ocarina:
-- * a random perk (could be hinted at in background near the crystal)
-- * full heal (hinted at in background near e.g. dark acave)
-- * idk

return hooks
