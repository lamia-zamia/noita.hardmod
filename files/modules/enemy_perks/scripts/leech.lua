local entity_id = GetUpdatedEntityID()
local root = EntityGetRootEntity(entity_id)
local x,y = EntityGetTransform(root)

local min_hp_drain_to = 0.04

local dmc = EntityGetFirstComponent(root, "DamageModelComponent")
if not dmc then return end
local hp, max_hp = ComponentGetValue2(dmc, "hp"), ComponentGetValue2(dmc, "max_hp")
local missing_hp = max_hp - hp
if missing_hp <= 0 then return end

local total_budget = 0
local logged_victims = {}

local victims = {}
for _,potential_victim in ipairs(EntityGetInRadiusWithTag(x, y, 85, "enemy")) do
	local vdmc = EntityGetFirstComponent(potential_victim, "DamageModelComponent")
	if vdmc and not (logged_victims[potential_victim] or potential_victim == root) then
		logged_victims[potential_victim] = true
		local total_hp = ComponentGetValue2(vdmc, "hp")
		local hp_donation_budget = total_hp - min_hp_drain_to
		if hp_donation_budget > 0 then
			total_budget = total_budget + hp_donation_budget
			victims[#victims+1] = {
				eid = potential_victim,
				dmc = vdmc,
				hp = total_hp,
				budget = hp_donation_budget
			}
		end
	end
end
if #victims == 0 then return end

local required_budget_percent = math.min(1, missing_hp / total_budget)


for _,victim in ipairs(victims) do
	EntityInflictDamage(victim.eid, victim.budget * required_budget_percent, "NONE", "blood tax", "BLOOD_SPRAY", 0, 0, root)
	EntityAddChild(victim.eid, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/leech_animation.xml", x, y))
	--ComponentSetValue2(victim.dmc, "hp", victim.hp - (victim.budget * required_budget_percent))
end

EntityInflictDamage(root, -total_budget, "DAMAGE_HEALING", "blood tax", "BLOOD_SPRAY", 0, 0)
GamePlaySound("data/audio/Desktop/animals.bank", "animals/worm/attack_bite", x, y)
