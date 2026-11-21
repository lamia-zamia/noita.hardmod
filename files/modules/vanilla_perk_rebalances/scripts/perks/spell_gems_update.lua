local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local MAX_EFFECT_DISTANCE = 100

local perk_entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(perk_entity_id)

local prev_max_eid = utils.GetInternalInt(perk_entity_id, "prev_max_eid", true)
local new_max = EntitiesGetMaxID()

for entity_id = prev_max_eid + 1, new_max do
	---@diagnostic disable-next-line: cast-type-mismatch
	---@cast entity_id entity_id

	if EntityHasTag(entity_id, "enemy") and utils.GetInternalInt(entity_id, "hardmod_spell_gems_script_added", true) == 0 then
		EntityAddComponent2(entity_id, "LuaComponent", {
			script_source_file = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/scripts/perks/spell_gems_try_drop_on_death.lua",
			execute_every_n_frame = -1,
			execute_on_removed = true,
		})
		utils.SetInternalInt(entity_id, "hardmod_spell_gems_script_added", 1)
		utils.SetInternalInt(perk_entity_id, "prev_max_eid", new_max)
	end
end
