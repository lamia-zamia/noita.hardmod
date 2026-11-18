dofile_once("data/scripts/status_effects/status_list.lua")

do return end

local cells_per_stain = 10

if fungal_trip_index == nil then
	local seen = {}
	local count = 0
	for _,effect in ipairs(status_effects) do
		if not seen[effect.id] then
			seen[effect.id] = true
			count = count + 1
			if effect.id == "TRIP" then
				fungal_trip_index = count + 1
				break
			end
		end
	end
	fungal_trip_material = CellFactory_GetType("fungi")
end

local entity_id = GetUpdatedEntityID()
local status = EntityGetFirstComponentIncludingDisabled(entity_id, "StatusEffectDataComponent")
local ingestion = EntityGetFirstComponentIncludingDisabled(entity_id, "IngestionComponent")
if status == nil or ingestion == nil or fungal_trip_index == nil then
	return
end

local stains = ComponentGetValue2(status, "stain_effects")
local stain = stains and stains[fungal_trip_index] or 0
if stain <= 0 then
	return
end

EntityRemoveStainStatusEffect(entity_id, "TRIP", 0)

fungal_trip_carry = (fungal_trip_carry or 0) + stain * cells_per_stain
local cells = math.floor(fungal_trip_carry)
if cells < 1 then
	return
end
fungal_trip_carry = fungal_trip_carry - cells

local stomach = ComponentGetValue2(ingestion, "ingestion_size")
EntityIngestMaterial(entity_id, fungal_trip_material, cells)
ComponentSetValue2(ingestion, "ingestion_size", stomach)
