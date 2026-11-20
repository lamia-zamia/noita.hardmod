local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

local hooks = {} ---@type hooks
local dir = "mods/noita.hardmod/files/modules/nerf_vanilla_cheeses/"

ModMagicNumbersFileAdd(dir.."magic_numbers.xml")


-- Nerf Stevari and Skoude to be 95% resistant to Physics Damage
local reduce_physics_damage = {
	"data/entities/animals/necromancer_shop.xml",
	"data/entities/animals/necromancer_super.xml",
	"data/entities/animals/necromancer.xml",
}
local polymorph_immunity = nxml.new_element("Entity", {name = "polymorph_immunity"}, {
	nxml.new_element("InheritTransformComponent"),
	nxml.new_element("GameEffectComponent", {
		effect = "PROTECTION_POLYMORPH"
	})
})
for _,path in ipairs(reduce_physics_damage) do
	for xml in nxml.edit_file(path) do
		--local dmc = xml:first_of("DamageModelComponent")
		--if dmc then
		--	local mults = dmc:first_of("damage_multipliers")
		--	if mults then mults.attr.physics_hit = "0.05" end
		--end

		xml:add_child(polymorph_immunity)
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
		ComponentObjectSetValue2(comp, "damage_multipliers", "physics_hit", 0.01)
	end
end

-- Fix cursed rock not damaging the player between chunks
for file in nxml.edit_file("data/entities/misc/rock_curse.xml") do
	local comp = file:first_of("AreaDamageComponent")
	if comp then
		comp:set("aabb_min.x", -256)
		comp:set("aabb_min.y", -256)
		comp:set("aabb_max.x", 256)
		comp:set("aabb_max.y", 256)
	end
end

-- Nerf Tablets to not lose mWhoShot when dragged out of the inventory
for xml in nxml.edit_file("data/entities/items/books/base_book.xml") do
	xml:add_child(
		nxml.new_element("LuaComponent", {
			_tags = "enabled_in_world",
			script_enabled_changed=dir.."scripts/check_player_cheese_throw.lua",
			execute_every_n_frame="-1",
		})
	)
	local proj_comp = xml:first_of("ProjectileComponent")
	if proj_comp then proj_comp.attr.damage = "0" end
end

for xml in nxml.edit_file("data/entities/player_base.xml") do
	local dmc = xml:first_of("DamageModelComponent")
	if dmc then
		local mults = dmc:first_of("damage_multipliers")
		if mults then mults.attr.physics_hit = "0.4" end
	end
end

-- nyehehe
ModLuaFileAppend("data/scripts/biomes/roadblock.lua", dir.."scripts/roadblock_append.lua")

-- no free tower wands 4 u
ModLuaFileAppend("data/scripts/biomes/tower_end.lua", dir.."scripts/tower_end_append.lua")

local tower_levels = {}
for i=1,10 do
	local biome = "data/biome/tower/solid_wall_tower_"..tostring(i)..".xml"
	tower_levels[biome] = "tower_visited_"..tostring(i)
end

function hooks.player_biome_changed(player, x, y, file,...)
	local flag = tower_levels[file]
	if not flag or GameHasFlagRun("tower_visited_all") or GameHasFlagRun(flag) then
		return
	end

	GameAddFlagRun(flag)
	print("tower progress:", flag)

	local all = true
	for _,level in pairs(tower_levels) do
		if not GameHasFlagRun(level) then
			all = false
			break
		end
	end

	if all then
		GameAddFlagRun("tower_visited_all")
		print("visited all!!")
		for _,level in pairs(tower_levels) do GameRemoveFlagRun(level) end
	end
end

return hooks
