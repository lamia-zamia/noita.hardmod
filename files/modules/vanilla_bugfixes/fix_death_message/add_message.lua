---I previously used `function damage_received(damage, message, attacker, is_fatal, projectile)`, however this does not pass `damage_type_bit_field`, which is a handy fallback.
---It unfortunately doesn't have Projectile and Attacker as separate, but that should be fine. Attacker here is hopefully the projectile, and from there the attacker can be
--- extrapolated from mWhoShot on the projectile. If attacker is not the projectile but a direct link to the caster, well fuck ig I'll have to use `damage_received` again.

function death(damage_type_bit_field, message, attacker, drop_items)
	local msg_translated = message:sub(1,1) == '$' and GameTextGetTranslatedOrNot(message) --if the message is a translation key, translate it
	if #msg_translated > 0 or #message > 0 then return end --If message is not empty, assume all is good and return early.

	local entity_id = GetUpdatedEntityID()
	local stats = EntityGetFirstComponent(entity_id, "GameStatsComponent")
	if not stats then return end
	if #ComponentGetTypeName(stats) == 0 then return end

	local function get_translation_or_nil(str)
		if str == nil then return end
		if str:sub(1,1) ~= '$' then str = '$' .. str end
		local tl = GameTextGetTranslatedOrNot(str)
		if #tl > 0 then return tl end
	end

	local function match_action(str) return get_translation_or_nil("$action_" .. (str or "")) end
	local function match_animal(str) return get_translation_or_nil("$animal_" .. (str or "")) end

	local function get_file_name(target) return EntityGetFilename(target):match("[^/]*$"):sub(1,-5) end

	local function get_projectile_filename_from_varcomp(target)
		for _,varcomp in ipairs(EntityGetComponent(target, "VariableStorageComponent") or {}) do
			if ComponentGetValue2(varcomp, "name") == "projectile_file" then
				return ComponentGetValue2(varcomp, "value_string"):match("[^/]*$"):sub(1,-5)
			end
		end
	end

	local funcs = {
		function(target) --check $action_[filename]
			return match_action(get_file_name(target))
		end,
		function(target) --check $action_[projectile_varcomp]
			return match_action(get_projectile_filename_from_varcomp(target))
		end,
		function(target) --check $[name]
			return get_translation_or_nil(EntityGetName(target))
		end,
		function(target) --check $animal_[filename]
			return match_animal(get_file_name(target))
		end,
		function(target) --check $[filename]
			return get_translation_or_nil(get_file_name(target))
		end,
	}

	local projectile
	local attacker_name
	if attacker ~= 0 then
		if projectile == 0 then
			for _,proj_comp in ipairs(EntityGetComponent(attacker, "ProjectileComponent") or {}) do
				local who_shot = ComponentGetValue2(proj_comp, "mWhoShot")
				if EntityGetIsAlive(who_shot) then
					projectile = attacker
					attacker = who_shot
					break
				end
			end
		end
		for _,func in ipairs(funcs) do
			attacker_name = func(attacker)
			if attacker_name ~= nil then break end
		end
	end

	local projectile_name
	if projectile then
		for _,func in ipairs(funcs) do
			projectile_name = func(projectile)
			if projectile_name ~= nil then break end
		end
	end

	local death_msg
	if projectile_name and attacker_name then
		if attacker_name:sub(-1) == 's' then
			death_msg = GameTextGet("$menugameover_causeofdeath_killer_cause_name_ends_in_s", attacker_name, projectile_name)
		else
			death_msg = GameTextGet("$menugameover_causeofdeath_killer_cause", attacker_name, projectile_name)
		end
	else
		death_msg = attacker_name or projectile_name
	end

	if not death_msg then --I don't know if this can occur, but if it can then neato. If not- well I can reuse this for a better death message mod in the future.
		local damage_bit_positions = {
			[0x1] = "$damage_melee", --"melee"
			[0x2] = "$damage_projectile", --"projectile"
			[0x4] = "$damage_explosion", --"explosion"
			[0x8] = "$hardmod_damage_bite", --"bite"
			[0x10] = "$damage_fire", --"fire"
			[0x20] = "$hardmod_damage_material", --"material"
			[0x40] = "$damage_fall", --"fall"
			[0x80] = "$damage_electricity", --"electricity"
			[0x100] = "$damage_drowning", --"drowning"
			[0x200] = "$hardmod_damage_physics_body_damaged", --"physics_body_damaged"
			[0x400] = "$damage_drill", --"drill"
			[0x800] = "$damage_slice", --"slice"
			[0x1000] = "$damage_ice", --"ice"
			[0x2000] = "$damage_healing", --"healing"
			[0x4000] = "$damage_physicshit", --"physics_hit"
			[0x8000] = "$damage_radioactive", --"radioactive"
			[0x10000] = "$damage_poison", --"poison"
			[0x20000] = "$hardmod_damage_material_with_flash", --"material_with_flash"
			[0x40000] = "$damage_overeating", --"overeating"
			[0x80000] = "$damage_curse", --"curse"
			[0x100000] = "$damage_holy", --"holy"
		}

		local damage_types = {}
		for value, translation_key in pairs(damage_bit_positions) do
			if bit.band(damage_type_bit_field, value) ~= 0 then
				damage_type_bit_field = damage_type_bit_field - value
				damage_types[#damage_types+1] = get_translation_or_nil(translation_key)
			end
		end

		if #damage_types == 0 then
			death_msg = "$hardmod_damage_none"
		else
			death_msg = ""
			for index, value in ipairs(damage_types) do
				death_msg = death_msg .. GameTextGetTranslatedOrNot(value) .. ", "
			end
			if damage_type_bit_field > 0 then death_msg = death_msg .. GameTextGetTranslatedOrNot("$hardmod_damage_unknown") .. ", " end
			death_msg = death_msg:sub(1, -3)
		end

		local prefix = #damage_types < 2 and "$hardmod_damage_type" or "$hardmod_damage_types"
		death_msg = GameTextGet(prefix, death_msg)
	end

	ComponentSetValue2(stats, "extra_death_msg", death_msg .. ComponentGetValue2(stats, "extra_death_msg"))
	local c = EntityCreateNew("remove_extra_death_msg")
	EntityAddChild(entity_id, c)
	EntityAddComponent2(c, "LuaComponent", {
		script_source_file = "mods/noita.hardmod/files/modules/vanilla_bugfixes/fix_death_message/remove_message.lua"
	})
	EntityAddComponent2(c, "VariableStorageComponent", {
		name = "hardmod_remove_string",
		value_string = death_msg
	})
end