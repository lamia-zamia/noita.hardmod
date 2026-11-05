local entity_id = GetUpdatedEntityID()
local x,y = EntityGetTransform(entity_id)
local material_inventory = EntityGetFirstComponent(entity_id, "MaterialInventoryComponent")
if not material_inventory then return end
local stored_gold = ComponentGetValue2(material_inventory, "count_per_material_type")

--owner and wallet stuff
local owner = EntityGetParent(entity_id)
if owner == 0 then return end
local wallet = EntityGetFirstComponent(owner, "WalletComponent")

dofile_once("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/gold_is_dust/gold_funcs.lua")

local persistent_data = {
	greed_stacks = GameGetGameEffectCount(owner, "EXTRA_MONEY"),
	entity_id = entity_id,
	x = x,
	y = y,
	owner = owner,
	wallet = wallet, --wallet can be nil
	material_inventory = material_inventory,
	stored_gold = stored_gold,
}

HardmodCustomGoldMaterials = {
	"hardmod.greedy_gold",
	"hardmod.greedy_gold.10",
	"hardmod.greedy_gold.100",
	"hardmod.bloody_gold",
	"hardmod.bloody_gold.10",
	"hardmod.bloody_gold.100",
}

for _,mat_name in ipairs(HardmodCustomGoldMaterials) do
	local amount = stored_gold[CellFactory_GetType(mat_name)+1]
	if amount ~= 0 then
		if GoldFunctions[mat_name] then
			local data = {
				pdata = persistent_data,
				amount = amount,
				material_name = mat_name,
				worth = 1,
			}
			for key, value in pairs(GoldFunctions[mat_name]) do
				data[key] = value
			end
			if data.func then data:func() else GoldFunctions.default(data) end
		end
	end
end