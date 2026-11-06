local utilities = {} ---@class eperk_utils
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local enemy_perks
local enemy_perks_indexed = {}

utilities.biome_levels = {
	default_biome_data = {
		level = 3,
		do_recursive_roll = true,
		--range = {0, 0},
		--custom_func = function(self, entity_id) end --return perk num
	},
	mines = 1, --mines
	collapsed_mines = 2,
	coal_pits = 2, --coal pits
	fungal_caverns = 3, --fungal caverns
	snowy_depths = 3, --snowy depths
	magical_temple = 4, --snowy depths
	hiisi_base = 4, --hiisi base
	jungle = 5, --jungle
	lukki_lair = 6, --lukki lair
	vault = 6,
	temple_of_the_art = 10,

	ancient_lab = 4,
	surface_desert = 7,
	surface_snowy = 7,
	wizards_den = 8,
	sandcave = 8,
	wandmart = 8,
	powerplant = {
		level = 6,
		range = {1, 2} --guaranteed 1-2 perks base
	},
	meat_realm = 9,
	sky = 12,
	hell = 12,

	holy_mountain = {
		level = 3,
		do_recursive_roll = false,
		custom_func = function(self, entity_id, x, y)
			local levels = {
				2,
				5,
				9,
				12,
				16,
				20,
				25,
			}

			local y_chunk_level = math.floor(y/512)
			local num = 0
			for i,stage_boundary in ipairs(levels) do
				if stage_boundary > y_chunk_level then break end
				num = i
			end

			return num
		end
	}
}

for biome,data in pairs(utilities.biome_levels) do
	if type(data) == "number" then
		utilities.biome_levels[biome] = {
			level = data
		}
	end
end

---function to give enemy perks
---@param entity_id entity_id
---@param perks_to_give int|table|nil pass number to pass X random perks, pass table to give specific selection of perks
---@param data table context passed to functions, used for both random selection and perk behaviour
function utilities.give_enemy_perks(entity_id, perks_to_give, data)
	local perks_to_give_type = type(perks_to_give)
	local amount_of_perks = perks_to_give_type == "number" and perks_to_give
		or perks_to_give_type == "table" and #perks_to_give
		or 1

	if amount_of_perks == 0 then return end

	-- do not give perks to entities who drop no gold
	for _,vsc_comp in ipairs(EntityGetComponent(entity_id, "VariableStorageComponent") or {}) do
		if ComponentHasTag(vsc_comp, "no_gold_drop") then return end
	end

	local x,y = EntityGetTransform(entity_id)
	local enemy_perks_handler
	for _,child in ipairs(EntityGetAllChildren(entity_id) or {}) do
		if EntityGetName(child) == "hardmod.enemy_perks" then enemy_perks_handler = child break end
	end
	if not enemy_perks_handler then
		enemy_perks_handler = EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/handler.xml", x, y)
		EntityAddChild(entity_id, enemy_perks_handler)
	end

	local has_death_handler
	for _,luacomp in ipairs(EntityGetComponent(entity_id, "LuaComponent") or {}) do
		if ComponentGetValue2(luacomp, "script_death") == "mods/noita.hardmod/files/modules/enemy_perks/perk_holder_died.lua" then has_death_handler = true break end
	end
	if not has_death_handler then
		EntityAddComponent2(entity_id, "LuaComponent", {
			script_death = "mods/noita.hardmod/files/modules/enemy_perks/perk_holder_died.lua"
		})
	end

	local already_held_perks = {}
	local how_many_of_each_perk = {}
	local enemy_perk_data
	for _,varcomp in ipairs(EntityGetComponent(enemy_perks_handler, "VariableStorageComponent") or {}) do
		if ComponentGetValue2(varcomp, "name") == "enemy_perk_data" then enemy_perk_data = varcomp break end
	end
	if not enemy_perk_data then
		enemy_perk_data = EntityAddComponent2(enemy_perks_handler, "VariableStorageComponent", {name = "enemy_perk_data"})
	else
		for perk_id in ComponentGetValue2(enemy_perk_data, "value_string"):gmatch("([^,]+)") do
			already_held_perks[#already_held_perks+1] = perk_id
			how_many_of_each_perk[perk_id] = (how_many_of_each_perk[perk_id] or 0) + 1
		end

	end

	data.already_held_perks = already_held_perks
	data.how_many_of_each_perk = how_many_of_each_perk

	local selected_perks = {}
	data.selected_perks = selected_perks --idk maybe someone can do some bullshit with this lmao
	if perks_to_give_type == "number" then
		for i=1, perks_to_give do
			local perk = utils.ConditionalRandomFromTable(enemy_perks, data)
			if not perk then return end
			perk:func(entity_id, data)
			selected_perks[#selected_perks+1] = perk
			already_held_perks[#already_held_perks+1] = perk.id
			how_many_of_each_perk[perk.id] = (how_many_of_each_perk[perk.id] or 0) + 1
		end
	elseif perks_to_give_type == "table" then
		for _,perk in ipairs(perks_to_give) do
			if type(perk) == "string" then
				perk = enemy_perks_indexed[perk]
			end
			perk:func(entity_id, data)
			selected_perks[#selected_perks+1] = perk
			already_held_perks[#already_held_perks+1] = perk.id
			how_many_of_each_perk[perk.id] = (how_many_of_each_perk[perk.id] or 0) + 1
		end
	end


	ComponentSetValue2(enemy_perk_data, "value_string", table.concat(already_held_perks, ","))

	if not EntityHasTag(entity_id, "hardmod_blessed") then
		EntityAddTag(entity_id, "hardmod_blessed")
	end

	for _,perk in ipairs(selected_perks) do
		if perk.post_func then perk:post_func(entity_id, data) end
	end
end


return function(eperks)
    enemy_perks = eperks
    for _,perk in ipairs(enemy_perks) do
        enemy_perks_indexed[perk.id] = perk
    end
    return utilities
end