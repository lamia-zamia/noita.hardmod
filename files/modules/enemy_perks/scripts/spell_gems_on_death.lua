local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local entity_id = GetUpdatedEntityID()

local function has_vsc(eid, variable_name)
	local vs_comps = EntityGetComponent(eid, "VariableStorageComponent")
	if vs_comps ~= nil then
		for _,vs_comp in pairs(vs_comps) do
			local var_name = ComponentGetValue2(vs_comp, "name")
			if var_name == variable_name then
				return true
			end
		end
	end
	return false
end
if has_vsc(entity_id, "no_gold_drop") then return end

local dmg_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "DamageModelComponent")
if dmg_comp then
	local max_hp = ComponentGetValue2(dmg_comp, "max_hp")

	-- scale from 2 gems at 100 HP, up to 10 gems at 1000+ HP
	local gems_to_drop = math.min( math.max( max_hp / 4, 2 ), 10 )
	-- very low-hp enemies drop only 1
	if max_hp < 2 then gems_to_drop = 1 end

	for i=1, gems_to_drop do
		local x, y = EntityGetTransform(entity_id)
		local offset_x = Random(-4, 4)
		local offset_y = Random(-4, 4)
		EntityLoad("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/items/spell_gem.xml", x + offset_x, y + offset_y)
	end
end
