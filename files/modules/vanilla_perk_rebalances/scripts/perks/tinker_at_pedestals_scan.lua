local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local entity_id = GetUpdatedEntityID()
local x, y = EntityGetTransform(entity_id)

for _,wand_id in pairs(EntityGetWithTag("wand")) do
	local already_spawned_aura = utils.GetInternalInt(wand_id, "hardmod_pedestal_tinker_aura_spawned", true)
	if already_spawned_aura == 0 then
		local itemcomp = EntityGetFirstComponent(wand_id, "ItemComponent")
		if itemcomp ~= nil then
			if not ComponentGetValue2(itemcomp, "has_been_picked_by_player") then
				local wx, wy = EntityGetTransform(wand_id)
				if not string.find(BiomeMapGetName(wx, wy), "holy") then
					EntityLoad("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/wand_tinkering_aura.xml", wx, wy)
					utils.SetInternalInt(wand_id, "hardmod_pedestal_tinker_aura_spawned", 1)
				end
			end
		end
	end
end
