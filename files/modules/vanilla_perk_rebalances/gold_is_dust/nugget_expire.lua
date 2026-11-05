if not GameHasFlagRun("hardmod.gold_is_dust_perk") then return end
local entity_id = GetUpdatedEntityID()
if EntityGetRootEntity(entity_id) ~= entity_id then return end
local x,y = EntityGetTransform(entity_id)

--do this in case some loser turns off my super cool and awesome better bloody nuggets
local vanilla_bloody

local material = "hardmod.greedy_gold"

--local healing = 0
local gold = 0
for _, varcomp in ipairs(EntityGetComponent(entity_id, "VariableStorageComponent") or {}) do
	local name = ComponentGetValue2(varcomp, "name")
	if name == "gold_value" then
		gold = gold + ComponentGetValue2(varcomp, "value_int")
	elseif name == "hp_value" then
		material = "hardmod.bloody_gold"
		--if ModSettingGet("gid.fix_bloody_gold") then
		--else
		--	healing = (healing + ComponentGetValue2(varcomp, "value_int")) or 0.16
		--	vanilla_bloody = true
		--end
	end
end

--[[ decided i dont really wanna account for this, idk maybe might fix it at some point
local bloody_values = {
	[0.016] = "GID_bloody_gold10",
	[0.008] = "GID_bloody_gold50",
	[0.003] = "GID_bloody_gold200",
	[0.0006] = "GID_bloody_gold1000",
	[0.00006] = "GID_bloody_gold10000",
	[0.000003] = "GID_bloody_gold200000",
}
if vanilla_bloody then material = bloody_values[healing/gold] or "GID_bloody_gold10" end
--]]


local amountx1 = gold
local amountx10 = 0
local amountx100 = 0

if amountx1 > 1000 then
	amountx10 = math.floor((amountx1 - 1000) / 100) * 10
	amountx1 = amountx1 - (amountx10 * 10)
end
if amountx10 > 1000 then
	amountx100 = math.floor((amountx10 - 1000) / 100) * 10
	amountx10 = amountx10 - (amountx100 * 10)
end

GameCreateParticle(material, x, y, amountx1, 0, 0, false)
GameCreateParticle(material .. ".10", x, y, amountx10, 0, 0, false)
GameCreateParticle(material .. ".100", x, y, amountx100, 0, 0, false)