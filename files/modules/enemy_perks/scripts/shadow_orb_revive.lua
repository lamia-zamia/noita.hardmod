local entity_id = GetUpdatedEntityID()

local path = EntityGetName(entity_id)
local perks
for _,varcomp in ipairs(EntityGetComponent(entity_id, "VariableStorageComponent") or {}) do
	if ComponentGetValue2(varcomp, "name") == "hardmod_stored_perks" then
		perks = ComponentGetValue2(varcomp, "value_string")
		break
	end
end

if not perks then EntityKill(entity_id) return end


local biome_index = dofile_once("mods/noita.hardmod/lib/biome_index.lua") ---@type biome_path_to_simple_id
local enemy_perks = dofile_once("mods/noita.hardmod/files/modules/enemy_perks/enemy_perks_list.lua")
local eperk_utils = dofile_once("mods/noita.hardmod/files/modules/enemy_perks/eperk_utilities.lua")(enemy_perks) ---@type eperk_utils

local target_perks = {}
for perk_id in perks:gmatch("([^,]+)") do
	target_perks[#target_perks+1] = perk_id
end

local x,y = EntityGetTransform(entity_id)
local eid = EntityLoad(path, x, y)

local is_boss = EntityHasTag(entity_id, "boss")

local biome = biome_index[DebugBiomeMapGetFilename(x, y)]
local biome_data = eperk_utils.biome_levels[biome] or eperk_utils.biome_levels.default_biome_data
local level = (is_boss and 5 or biome_data.level) --if is_boss, override biome level
	+ (tonumber(SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")) or 0) -- + NG+ iteration
	+ (GetParallelWorldPosition(x, y) ~= 0 and 3 or 0) -- +3 if in a PW

local player = EntityGetWithTag("player_unit")[1]
local player_poly_identity
if not player then
	player = EntityGetWithTag("polymorphed_player")[1] or EntityGetWithTag("polymorphed_cessation")[1]
	player_poly_identity = {path = EntityGetFilename(player), name = EntityGetName(player)}
end

local data = {
	x = x, y = y,
	biome = biome,
	level = level,
	target_enemy = entity_id,
	player = player,
	player_poly_identity = player_poly_identity,
	is_boss = is_boss,
}

eperk_utils.give_enemy_perks(eid, target_perks, data)

EntityKill(entity_id)