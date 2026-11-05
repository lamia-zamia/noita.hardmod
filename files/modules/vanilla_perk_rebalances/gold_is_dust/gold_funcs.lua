GoldFunctions = {}

local blood_heal = function(d)
	GoldFunctions.default(d)
	local damage_comp = EntityGetFirstComponent(d.pdata.owner, "DamageModelComponent")
	if not damage_comp then return end
	local heal_amount = d.amount * d.worth * 2^d.pdata.greed_stacks * 0.004
	EntityInflictDamage(d.pdata.owner, -heal_amount, "DAMAGE_HEALING", "blood money", "NONE", 0, 0)
end

GoldFunctions = {
	default = function(d)
		local wallet = d.pdata.wallet
		if not wallet then print("fail") return end
		local income = d.amount * d.worth * 2^d.pdata.greed_stacks
		ComponentSetValue2(wallet, "money", ComponentGetValue2(wallet, "money") + income)
		GameEntityPlaySoundLoop(d.pdata.owner, "sound_pick_gold_sand", 1)
		AddMaterialInventoryMaterial(d.pdata.entity_id, d.material_name, 0)
	end,
	["hardmod.greedy_gold"] = {

	},
	["hardmod.greedy_gold.10"] = {
		worth = 10
	},
	["hardmod.greedy_gold.100"] = {
		worth = 100
	},
	["hardmod.bloody_gold"] = {
		func = blood_heal,
	},
	["hardmod.bloody_gold.10"] = {
		func = blood_heal,
		worth = 10,
	},
	["hardmod.bloody_gold.100"] = {
		func = blood_heal,
		worth = 100,
	},
}