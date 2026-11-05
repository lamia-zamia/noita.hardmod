---@diagnostic disable: undefined-global

---Maximum modifier count per biome (uses `default` for non specified biomes)
MaxBiomeModifierCount = { default = 1 }

---Chances for a biome to have a modifier (uses `default` for non specified biomes)
BiomeModifierChances = {
	default = 0.1,
	coalmine = 0.2,
	excavationsite = 0.15,
}

---Force-applies this modifier to a biome if the biome didn't get a modifier
ForcedBiomeModifiers = {
  	wandcave = "FOG_OF_WAR_CLEAR_AT_PLAYER", wizardcave = "FOG_OF_WAR_CLEAR_AT_PLAYER",
	alchemist_secret = "FOG_OF_WAR_CLEAR_AT_PLAYER",
	mountain_top = "FREEZING", mountain_floating_island = "FREEZING",
  	winter = "FREEZING", winter_caves = "FREEZING_COSMETIC",
	lavalake = "HOT", desert = "HOT",
	pyramid_entrance = "HOT", pyramid_left = "HOT", pyramid_top = "HOT", pyramid_right = "HOT",
	watercave = "MOIST",
	rainforest_dark = "FOG_OF_WAR_REAPPEARS",
	lake = { id = "MOIST", chance = 0.75 },
	fungicave = { id = "MOIST", chance = 0.5 },
}

local modifiers = {}
local modifiers_by_id = {}
local total_weight = 0

---Patches biome modifiers
function PatchModifiers(tbl)
	for _,modifier in pairs(biome_modifiers) do
    if tbl[modifier.id] then
		local edit = tbl[modifier.id]
      	for k,v in pairs(edit) do modifier[k] = v end

		if edit.remove_from_biomes then
			modifier.does_not_apply_to_biome = modifier.does_not_apply_to_biome or {}
			for _,v in pairs(edit.remove_from_biomes) do table.insert(modifier.does_not_apply_to_biome, v) end
		end
    end
	end
end

---Adds new biome modifiers
function AddModifiers(tbl)
	for _,modifier in pairs(tbl) do
		table.insert(biome_modifiers, modifier)
	end
end

---If `to_biome` is passed, adds all biome names from `tbl` to an existing biome group that contains `to_biome`. Otherwise, adds a new biome group `tbl`.
---@param tbl string[]
---@param to_biome string?
function AddBiomeGroup(tbl, to_biome)
	if to_biome then
		local add_to = nil
		for _,list in pairs(biomes) do
		for _,biome in pairs(list) do
			if biome == to_biome then
			add_to = list
			break
			end
		end
		end

		if not add_to then return end
		for _,biome in pairs(tbl) do
			table.insert(add_to, biome)
		end
	else
		table.insert(biomes, tbl)
	end
end

---@class InjectSpawnsEntity
---@field to table
---@field prob integer
---@field min_count integer?
---@field max_count integer?
---@field offset_y integer?
---@field entity string

---@param spawns InjectSpawnsEntity[]
function InjectSpawns(spawns)
	for _,spawn in pairs(spawns) do
		inject_spawn(spawn.to, spawn.prob, {
			prob = 0,
			min_count = spawn.min_count or 1, max_count = spawn.max_count or 1,
			offset_y = spawn.offset_y or 0,
			entity = spawn.entity
		})
	end
end

local function get_modifier_table()
	if #modifiers > 0 then return end

	for _,modifier in pairs(biome_modifiers) do
		if modifier.requires_flag and not HasFlagPersistent(modifier.requires_flag) then goto continue end

		if modifier.apply_only_to_biome then
			modifier.whitelist_biomes = {}
			for _,biome in pairs(modifier.apply_only_to_biome) do
				modifier.whitelist_biomes[biome] = true
			end
		end

		if modifier.does_not_apply_to_biome then
			modifier.blacklist_biomes = {}
			for _,biome in pairs(modifier.does_not_apply_to_biome) do
				modifier.blacklist_biomes[biome] = true
			end
		end

		table.insert(modifiers, modifier)
		total_weight = total_weight + modifier.probability
		modifiers_by_id[modifier.id] = modifier

		::continue::
	end
end

local function random_biome_modifier()
	if total_weight == 0 then get_modifier_table() end

	local rnd = Randomf(0, total_weight)
	for _,entry in pairs(modifiers) do
		if rnd <= entry.probability then return entry end
		rnd = rnd - entry.probability
	end

	return modifiers[#modifiers]
end

local function pick_modifiers_for(biome, count)
	local picked = {}
	local picked_categories = {}
	local picked_ids = {}

	for _=0,100 do
		local modifier = random_biome_modifier()

		if
			picked_ids[modifier.id]
			or (modifier.category and picked_categories[modifier.category])
			or (modifier.blacklist_biomes and modifier.blacklist_biomes[biome])
			or (modifier.whitelist_biomes and not modifier.whitelist_biomes[biome])
		then
			goto continue
		end

		table.insert(picked, modifier)

		picked_ids[modifier.id] = true
		if modifier.category then
			picked_categories[modifier.category] = true
		end

		if #picked >= count then break end

		::continue::
	end

	return picked
end

local function resolve_modifier(modifier)
	if not modifier then return end

	local id
	local chance = 1

	if type(modifier) == "table" then
		id = modifier.id
		chance = modifier.chance or 1
	else
		id = modifier
	end

	if Randomf() > chance then return end

	if type(id) == "table" then
		local list = {}
		for _,mod in pairs(id) do
			table.insert(modifiers_by_id[mod])
		end

		return list
	else
		return { modifiers_by_id[id] }
	end
end

function get_modifier_mappings()
	local result = {}

	get_modifier_table()
	SetRandomSeed(347893, 90734)
	rnd = random_create(347893, 90734)

	local total_count = 0

	for _,biome_names in pairs(biomes) do
		local biome = biome_names[1]
		local chance = BiomeModifierChances[biome] or BiomeModifierChances.default
		local max = MaxBiomeModifierCount[biome] or MaxBiomeModifierCount.default
		if max == 0 or Randomf() > chance then goto continue end

		local count = 1
		if max > 1 then
			for _=1,max-1 do
				if Randomf() <= chance then
					count = count + 1
				end
			end
		end

		local list = pick_modifiers_for(biome, count)
		total_count = total_count + #list

		for _,name in pairs(biome_names) do
			result[name] = list
		end

		::continue::
	end

	for biome,modifier in pairs(ForcedBiomeModifiers) do
		local mod = resolve_modifier(modifier)
		if mod and not result[biome] then
			result[biome] = mod
			total_count = total_count + #mod
		end
	end

	return result
end

local function string_starts(str, start)
  return string.sub(str, 1, #start) == start
end

-- called from init_biome_modifiers
function apply_modifier_from_data(name, list)
	local filename = name
	if not string_starts(filename, "data/") and not string_starts(filename, "mods/") then
		filename = "data/biome/"..name..".xml"
	end

	SetRandomSeed(347893, 90734)
	rnd = random_create(347893, 90734)

	for _,modifier in pairs(list) do
		modifier.action(name, filename)
	end

	if #list == 1 then
		local modifier = list[1]
		---@diagnostic disable-next-line: param-type-mismatch
		BiomeSetValue(filename, "mModifierUIDescription", modifier.ui_description)
		---@diagnostic disable-next-line: param-type-mismatch
		BiomeSetValue(filename, "mModifierUIDecorationFile", modifier.ui_decoration_file or "")
	elseif #list > 1 then
		local text = GameTextGet("$hardmod_biomemodifier_multiple_active", tostring(#list))
		---@diagnostic disable-next-line: param-type-mismatch
		BiomeSetValue(filename, "mModifierUIDescription", text)
	end
end

function biome_modifiers_inject_spawns(name)
	local mappings = get_modifier_mappings()[name] or {}
	for _,modifier in pairs(mappings) do
		if modifier.inject_spawns_action then
			modifier.inject_spawns_action(name)
		end
	end
end

function apply_modifier() end
function apply_modifier_if_has_none() end

AddModifiers({ biome_modifier_cosmetic_freeze, biome_modifier_fog_of_war_clear_at_player })
PatchModifiers({
	FUNGAL = { category = "alternative" },
	FLOODED = { category = "alternative" },
	GAS_FLOODED = { category = "alternative" },
	FREEZING = { category = "temperature" },
	MOIST = { category = "temperature" },
	HOT = { category = "temperature" },
	FREEZING_COSMETIC = { category = "temperature" },
	FOG_OF_WAR_REAPPEARS = { category = "fog" },
	FOG_OF_WAR_CLEAR_AT_PLAYER = { category = "fog" },
	HIGH_GRAVITY = { category = "gravity" },
	LOW_GRAVITY = { category = "gravity" },
	GOLD_VEIN = { category = "gold" },
	GOLD_VEIN_SUPER = { category = "gold" },
	PERFORATED = { category = "worms" },
	WORMY = { category = "worms" },

	-- no categories for these
	-- CONDUCTIVE = { category = "" },
	-- PLANT_INFESTED = { category = "" },
	-- FURNISHED = { category = "" },
	-- BOOBY_TRAPPED = { category = "" },
	-- SPOOKY = { category = "" },
	-- GRAVITY_FIELDS = { category = "" },
	-- SHIELDED = { category = "" },
	-- PROTECTION_FIELDS = { category = "" },
	-- OMINOUS = { category = "" },
	-- INVISIBILITY = { category = "" },
})
