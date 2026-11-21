---@type biome_path_to_simple_id
local biome_index

local enemy_biome_multipliers = {
	-- ["balls"] = { hp = 6942, speed = 0.1 },
	["fungal_caverns"] = { hp = 1.2 },
	["jungle"] = { hp = 2 },
	["ancient_lab"] = { hp = 2 },
	["magical_temple"] = { hp = 2 },
	["lukki_lair"] = { hp = 2.5 },
	["vault"] = { hp = 2.5 },
	["temple_of_the_art"] = { hp = 3 },
	["wizards_den"] = { hp = 3 },

	["surface_forest"] = { hp = 3, speed = 0.75 },
	["surface_desert"] = { hp = 3, speed = 0.75 },
	["pyramid"] = { hp = 3, speed = 0.5 },
	["sandcave"] = { hp = 2 },

	["wandmart"] = { hp = 4 },
	["frozen_vault"] = { hp = 4 },
	["tower"] = { hp = 4, speed = 0.5 },
	["cloudscape"] = { hp = 3, speed = 0.5 },
	["powerplant"] = { hp = 2 },

	["meat_realm"] = { hp = 6 },
	["hell"] = { hp = 6, speed = 0.25 },
	["sky"] = { hp = 6, speed = 0.25 },
}

function HardmodTransformEnemy(eid, tbl)
	if EntityHasTag(eid, "hardmod_mult_applied") then return end
	if EntityHasTag(eid, "boss") then return end

	if not biome_index then
		biome_index = dofile_once("mods/noita.hardmod/lib/biome_index.lua")
	end

	local x, y = EntityGetTransform(eid)
	local biome = biome_index[DebugBiomeMapGetFilename(x, y)]
	if not biome then return end

	tbl = tbl or enemy_biome_multipliers
	local multipliers = tbl[biome]
	if not multipliers then return end

	local dmc = EntityGetFirstComponent(eid, "DamageModelComponent")
	if multipliers.hp and dmc then
		local max_hp = ComponentGetValue2(dmc, "max_hp")
		local new_hp = max_hp * multipliers.hp

		ComponentSetValue2(dmc, "max_hp", new_hp)
		ComponentSetValue2(dmc, "hp", new_hp)
	end

	local aicomp = EntityGetFirstComponent(eid, "AnimalAIComponent")
	if multipliers.speed and aicomp then
		local melee = ComponentGetValue2(aicomp, "attack_melee_frames_between")
		local ranged = ComponentGetValue2(aicomp, "attack_ranged_frames_between")

		ComponentSetValue2(aicomp, "attack_melee_frames_between", (melee or 0) * multipliers.speed)
		ComponentSetValue2(aicomp, "attack_ranged_frames_between", (ranged or 0) * multipliers.speed)
	end

	EntityAddTag(eid, "hardmod_mult_applied")
end

return enemy_biome_multipliers
