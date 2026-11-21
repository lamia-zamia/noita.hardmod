local EZWand = dofile_once("mods/noita.hardmod/lib/ezwand.lua")

local blacklisted_spells = {
	HARDMOD_ALT_FIRE_ANYTHING = true,
	RESET = true,
}

local function generate_spells(wand, level)
	wand:RemoveSpells()

	local x, y = EntityGetTransform(wand.entity_id)
	local spell_count = (level * 3) + Random(-1, 1)
	spell_count = math.min(math.max(spell_count, 3), wand.capacity)

	for i=1,spell_count do
		local spell = nil
		local j = 1

		while not spell or blacklisted_spells[spell] do
			spell = GetRandomAction(x, y, level, i * 100 + j)
			j = j + 1
		end

		wand:AddSpells(spell)
	end
end

local function host_evil_ghost(wand, level)
	local wand_entity = wand.entity_id
	local x, y = EntityGetTransform(wand_entity)

	-- turn the new wand particles red
	local spe_comp = EntityGetFirstComponentIncludingDisabled(wand_entity, "SpriteParticleEmitterComponent")
	if spe_comp then
		ComponentSetValue2(spe_comp, "color", 1, 0.25, 0.25, 0.5)
	end

	EntityAddTag(wand_entity, "hardmod_evil_wand")
	EntityAddComponent2(wand_entity, "LuaComponent", {
		_tags = "hardmod_evil_wand_temp",
		script_item_picked_up = "mods/noita.hardmod/files/modules/haunted_wands/scripts/evil_wand_on_pickup.lua",
		execute_every_n_frame = -1,
	})
	EntityAddComponent2(wand_entity, "LuaComponent", {
		_tags = "hardmod_evil_wand_temp",
		script_source_file = "mods/noita.hardmod/files/modules/haunted_wands/scripts/evil_wand_update.lua",
		execute_every_n_frame = 6,
	})
	EntityAddComponent2(wand_entity, "VariableStorageComponent", {
		name = "hardmod_wand_level",
		value_int = level,
	})
	EntityAddComponent2(wand_entity, "AudioLoopComponent", {
		_tags = "hardmod_evil_wand_temp",
		file = "data/audio/Desktop/projectiles.bank",
		event_name = "player_projectiles/epilogue/wall/movement_loop",
		m_volume = 0.3,
		auto_play_if_enabled = true,
	})

	EntityAddChild(wand_entity,
		EntityLoad("mods/noita.hardmod/files/modules/haunted_wands/entities/evil_wand_particles.xml", x, y))

	generate_spells(wand, math.max(level - 1, 0))
end

local _generate_gun = generate_gun
function generate_gun(cost, level, force_unshuffle)
	local eid = GetUpdatedEntityID()
	local x, y = EntityGetTransform(eid)

	-- summoned in ./biome_scripts_append.lua
	local evil_pedestal = EntityGetInRadiusWithTag(x, y, 5, "hardmod_evil_pedestal")[1]
	if evil_pedestal then
		EntityKill(evil_pedestal)

		level = math.min(level + 1, 6)
		_generate_gun(cost, level, force_unshuffle)

		local wand = EZWand(eid)
		if wand.capacity >= 5 then
			host_evil_ghost(wand, level)
		end
	else
		_generate_gun(cost, level, force_unshuffle)
	end
end
