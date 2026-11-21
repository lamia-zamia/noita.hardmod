local max_icons_displayed = 4
local y_offset_amount = 14
local icon_buffer = 10
local z_index = -.3

local half_icon_buffer = icon_buffer*.5


local entity_id = GetUpdatedEntityID()
local root = EntityGetRootEntity(entity_id)

if entity_id == root then EntityKill(entity_id) return end

local enemy_perks_indexed = dofile_once("mods/noita.hardmod/files/modules/enemy_perks/enemy_perks_index.lua")

local enemy_perk_data
for _,varcomp in ipairs(EntityGetComponent(entity_id, "VariableStorageComponent") or {}) do
	if ComponentGetValue2(varcomp, "name") == "enemy_perk_data" then enemy_perk_data = varcomp break end
end


local all_eperks = {}
for perk_id in ComponentGetValue2(enemy_perk_data, "value_string"):gmatch("([^,]+)") do
	all_eperks[#all_eperks+1] = enemy_perks_indexed[perk_id]
end
ComponentSetValue2(enemy_perk_data, "value_int", #all_eperks)

local offset_y = 0
for _,hitbox in ipairs(EntityGetComponent(root, "HitboxComponent") or {}) do
	offset_y = math.max(offset_y, -ComponentGetValue2(hitbox, "aabb_min_y"))
end
offset_y = offset_y + y_offset_amount
for _,spr_comp in ipairs(EntityGetComponent(entity_id, "SpriteComponent") or {}) do
	EntityRemoveComponent(entity_id, spr_comp)
end


table.sort(all_eperks, function(a, b)
	return a.priority > b.priority
end)
local unique_eperks = {}
local how_many_of_each_perk = {}
for _,eperk in ipairs(all_eperks) do
	local perk_id = eperk.id
	if not how_many_of_each_perk[perk_id] then
		unique_eperks[#unique_eperks+1] = eperk
		how_many_of_each_perk[perk_id] = 1
	else
		how_many_of_each_perk[perk_id] = how_many_of_each_perk[perk_id] + 1
	end
end


local num_icons = math.min(#unique_eperks, max_icons_displayed)
local spr_comps = {}
for i=1,num_icons do
	local eperk = unique_eperks[i]
	local is_etc = i == max_icons_displayed and #unique_eperks > max_icons_displayed
	local stacks = is_etc and #unique_eperks-i or how_many_of_each_perk[eperk.id]-1
	local sprite = is_etc and "mods/noita.hardmod/files/modules/enemy_perks/perk_icons/expand.png" or eperk.icon
	for j=0, stacks do
		local alpha = 1-(j*.2)
		if alpha <= 0 then goto continue end
		spr_comps[#spr_comps+1] = EntityAddComponent2(entity_id, "SpriteComponent", {
			offset_x = -((i-1)*icon_buffer-num_icons*half_icon_buffer),
			offset_y = offset_y-(j*2),
			alpha = alpha,
			image_file = sprite,
			z_index = z_index+(j*.001),
			never_ragdollify_on_death = true,
		})
	end
	::continue::
end



for _,perk in ipairs(unique_eperks) do
	if perk.func_handler then
		perk:func_handler(entity_id, root, spr_comps)
	end
end