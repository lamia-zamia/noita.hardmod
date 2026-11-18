local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local biome_index = dofile_once("mods/noita.hardmod/lib/biome_index.lua")

local _spawn_hp = spawn_hp
function spawn_hp(x, y)
	_spawn_hp(x, y)
	EntityLoad("mods/noita.hardmod/files/modules/trial_perks/entities/perks/trial_perk_finish.xml", x - 200, y + 20)
end

local function try_reroll_trial_perks(x, y)
	local nearby_perks = EntityGetInRadiusWithTag(x, y, 500, "perk")
	for _,perk in ipairs(nearby_perks) do
		local perk_id = utils.GetInternalString(perk, "perk_id") or ""
		if perk_id == "HARDMOD_TIME_TRIAL" or perk_id == "HARDMOD_GLASS_HEART" then
			-- delete the trial perk
			local perk_x, perk_y = EntityGetTransform(perk)
			EntityKill(perk)

			-- spawn a new one (does not consider its neighbours so might spawn a duplicate)
			dofile_once("data/scripts/perks/perk.lua")
			perk_spawn_random(perk_x, perk_y)
		end
	end
end

local _spawn_all_perks = spawn_all_perks
function spawn_all_perks(x, y)
	_spawn_all_perks(x, y)

	local biome = biome_index[DebugBiomeMapGetFilename(x, y + 500)]
	if biome == nil or (biome == "temple_of_the_art" and GetParallelWorldPosition(x, y) ~= 0) then
		try_reroll_trial_perks(x, y)
	end
end
