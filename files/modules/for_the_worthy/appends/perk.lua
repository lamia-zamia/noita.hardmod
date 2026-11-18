local hell_perk_remap = {
	PROTECTION_EXPLOSION = "HARDMOD_HELL_PROTECTION_EXPLOSION",
	EXPLODING_CORPSES = "HARDMOD_HELL_EXPLODING_CORPSES",
	PROTECTION_ELECTRICITY = "HARDMOD_HELL_PROTECTION_ELECTRICITY",
	PROTECTION_MELEE = "HARDMOD_HELL_PROTECTION_MELEE",
	CONTACT_DAMAGE = "HARDMOD_HELL_CONTACT_DAMAGE",

	HARDMOD_PROTECTION_ELECTRIC_STUN = "HARDMOD_HELL_PROTECTION_ELECTRICITY",
	HARDMOD_PROTECTION_FREEZE = "HARDMOD_HELL_PROTECTION_MELEE",
}

local hell_remove_perks = {
	HARDMOD_TINKER_AT_PEDESTALS = true,
	HARDMOD_PERK_SPELL_GEMS = true,
	HARDMOD_ITEM_IMMUNITIES = true,
	IRON_STOMACH = true,
	HUNGRY_GHOST = true,
	PROJECTILE_SLOW_FIELD = true,
	SHIELD = true,
	SAVING_GRACE = true,
	PEACE_WITH_GODS = true,
	INVISIBILITY = true,
}

local function remap_perks()
	if hardmod_hell_remapped then return end

	for _,perk in pairs(perk_list) do
		if hell_remove_perks[perk.id] then
			perk.not_in_default_perk_pool = true
		end
	end

	hardmod_hell_remapped = true
end

local orig_perk_spawn = perk_spawn
function perk_spawn(x, y, id, ...)
	if GameHasFlagRun("hardmod_hell") then
		id = hell_perk_remap[id] or id

		-- shouldnt happen
		if hell_remove_perks[id] then
			id = "LEGGY_FEET"
		end
	end

	return orig_perk_spawn(x, y, id, ...)
end

local orig_perk_get_spawn_order = perk_get_spawn_order

function perk_get_spawn_order(...)
	if GameHasFlagRun("hardmod_hell") and not hardmod_hell_remapped then
		remap_perks()
	end

	return orig_perk_get_spawn_order(...)
end
