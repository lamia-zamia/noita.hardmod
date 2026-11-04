local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local hooks = {}
local directory = "mods/noita.hardmod/files/modules/nerf_vanilla_cheeses/"
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml



ModMagicNumbersFileAdd(directory.."magic_numbers.xml")


-- Nerf Stevari and Skoude to be 95% resistant to Physics Damage
local reduce_physics_damage = {
	"data/entities/animals/necromancer_shop.xml",
	"data/entities/animals/necromancer_super.xml",
	"data/entities/animals/necromancer.xml",
}
for _,path in ipairs(reduce_physics_damage) do
	for xml in nxml.edit_file(path) do
		local dmc = xml:first_of("DamageModelComponent")
		if dmc then
			local mults = dmc:first_of("damage_multipliers")
			if mults then mults.attr.physics_hit = "0.05" end
		end
	end
end


-- Nerf Tannerkivi to not work on Extremely Dense Rock
function hooks.edit_material(elem)
    local mat_name = elem.attr.name
    if mat_name == "rock_hard_border" or mat_name == "rock_hard" then
        elem.attr.tags = elem.attr.tags:gsub(utils.escape(",[earth]"), "")
    end
end

-- Tablets & statues are no more
function hooks.new_eid(eid)
	if not EntityHasTag(eid, "enemy") then return end

	local dmc = EntityGetComponent(eid, "DamageModelComponent")
	if not dmc then return end

	for _,comp in pairs(dmc) do
		-- :)
		ComponentObjectSetValue2(comp, "damage_multipliers", "physics_hit", 0.001)
	end
end

-- Fix cursed rock not damaging the player between chunks
for file in nxml.edit_file("data/entities/misc/rock_curse.xml") do
  local comp = file:first_of("AreaDamageComponent")
  if comp then
    comp:set("aabb_min.x", -257)
    comp:set("aabb_min.y", -257)
    comp:set("aabb_max.x", 257)
    comp:set("aabb_max.y", 257)
  end
end

-- Nerf Tablets to not lose mWhoShot when dragged out of the inventory
for xml in nxml.edit_file("data/entities/items/books/base_book.xml") do
	xml:add_child(
		nxml.new_element("LuaComponent", {
			_tags = "enabled_in_world",
			script_enabled_changed=directory.."scripts/check_player_cheese_throw.lua",
			execute_every_n_frame="-1",
		})
	)
end


return hooks
