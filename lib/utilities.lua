--Useful functions.
---@class utils
local utils = {}

-- de-patterning function for dealing with string.gsub() and other pattern-utilising Lua functions.
---@param str string
---@return string
---@return integer
function utils.escape(str) return str:gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1") end

-- Convenient function to simplify modifying files, gsub \r\n to \n to edit multiple lines at a time.
---@param file string filepath
---@param target string target you wish to replace
---@param sub string what you wish to replace it with
function utils.modifile(file, target, sub)
	ModTextFileSetContent(file, ModTextFileGetContent(file):gsub("\r\n", "\n"):gsub(utils.escape(target), sub))
end

---@class ModifileReplacement
---@field from string Search string
---@field to string? String to replace to (defaults to `from` if you use `insert_before`/`insert_after`)
---@field insert_before string? String to insert before the result
---@field insert_after string? String to insert after the result
---@field pattern boolean? Use `from` as a pattern instead of escaping it
---@field count integer? Amount of max replacements (e.g. 1 = only the first instance)

---More advanced version of `modifile`
---@param file string filepath
---@param replacements ModifileReplacement[] Array of replacements to apply to the file
function utils.patchifile(file, replacements)
	local content = ModTextFileGetContent(file):gsub("\r\n", "\n")
	for _,replacement in pairs(replacements) do
		local from = replacement.pattern and replacement.from or utils.escape(replacement.from)
		local to = replacement.to or replacement.from

		if replacement.insert_before then to = replacement.insert_before..to end
		if replacement.insert_after then to = to..replacement.insert_after end

		content = content:gsub(from, to, replacement.count)
	end

	ModTextFileSetContent(file, content)
end

---handy func i stole that converts an entire table to string, grabbed from [here](https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console)
---@param o table
---@return string
function utils.dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. utils.dump(v) .. ','
		end
		return s .. '} '
	else
		return tostring(o)
	end
end

---a version of the `dump()` function but with formatting
---@param o table
---@param q bool? should keys be in quotes
---@return string
function utils.dumpf(o, q, r)
	r = r or 0
	local _t = ('    '):rep(r)
	local t = type(o)
	if t == 'table' then
		local s = '{\n'
		local table_is_empty = true
		for k,v in pairs(o) do
			table_is_empty = false
			if type(k) == 'number' then
				k = '['..k..']'
			elseif q then
				k = '["'..k..'"]'
			end
			s = s .. _t .. '    '..k..' = ' .. utils.dumpf(v,q,r+1) .. ',\n'
		end
		if table_is_empty then
			return s:sub(1, -2) .. '}'
		else
			return s .. _t .. '}'
		end
	elseif t == "string" then
		return '"' .. tostring(o):gsub("\n", "\\n") .. '"'
	else
		return tostring(o)
	end
end



function utils.MatchDateLocal(check_date)
	local current = {}
	current.year, current.month, current.day, current.hour, current.minute, current.second, current.jussi, current.mammi = GameGetDateAndTimeLocal()
	for unit,value in pairs(check_date) do
		if current[unit] ~= value then return false end
	end
	return true
end


---@class (exact) Weighted
---@field weight number

---@class (exact) Seed
---@field [1] number
---@field [2] number

---@generic T : Weighted
---@param t T[]
---@return T
---Function for picking a random table entry on `weight` as weight
function utils.RandomFromTable(t)
	local total_weight = 0
	for _, entry in ipairs(t) do
		total_weight = total_weight + entry.weight
	end

	local rnd = Randomf(0, total_weight)
	for _, entry in ipairs(t) do
		if rnd <= entry.weight then
			return entry
		else rnd = rnd - entry.weight end
	end
	return t[#t]
end

---@generic T : Weighted
---@param t T[]
---@param context any This is passed into the condition function
---@param seed Seed|nil If a seed is passed, it will use `ProceduralRandomFromTable` instead of `RandomFromTable`.
---@return T|nil
---Compiles entries from `t` into a new table based on optional `condition` value in the entry and passes it through `RandomFromTable`. `context` is passed into the function as a parameter.
function utils.ConditionalRandomFromTable(t, context, seed)
	local temp = {}
	for _, entry in ipairs(t) do
		if entry.condition and not entry:condition(context) then goto continue end
		temp[#temp+1] = entry
		::continue::
	end

	if #temp == 0 then return end
	if seed then return utils.ProceduralRandomFromTable(temp, seed) else return utils.RandomFromTable(temp) end
end

---@generic T : Weighted
---@param t T[]
---@param seed Seed
---@return T
---Function for picking a procedurally random table entry on `weight` as weight based on `seed`
function utils.ProceduralRandomFromTable(t, seed)
	local total_weight = 0
	for _, entry in ipairs(t) do
		total_weight = total_weight + entry.weight
	end

	local rnd = ProceduralRandomf(seed[1], seed[2], 0, total_weight)
	for _, entry in ipairs(t) do
		if rnd <= entry.weight then
			return entry
		else rnd = rnd - entry.weight end
	end
	return t[#t] --Randomf has a miniscule chance to overflow
end


---simple func to get herd id, mostly for other funcs in this file to utilise
---@param entity_id entity_id
---@return int
function utils.GetHerdID(entity_id)
	local genome_comp = EntityGetFirstComponent(entity_id, "GenomeDataComponent")
	if genome_comp then return ComponentGetValue2(genome_comp, "herd_id")
	else return 0 end
end

---Replacement function for the vanilla `utilities.lua` function, `shoot_projectile()`.
---@param shooter entity_id?
---@param entity_file string filepath to projectile.xml
---@param x number
---@param y number
---@param vel_x number?
---@param vel_y number?
---@param send_message bool?
---@return entity_id
function utils.ShootProjectile(shooter, entity_file, x, y, vel_x, vel_y, send_message)
	---@type entity_id
	---@diagnostic disable-next-line: assign-type-mismatch
	shooter = shooter or 0
	local entity_id = EntityLoad(entity_file, x, y)
	vel_x = vel_x or 0
	vel_y = vel_y or 0
	send_message =  send_message or true

	local herd_id = utils.GetHerdID(shooter)

	GameShootProjectile(shooter, x, y, x+vel_x, y+vel_y, entity_id, send_message)

	for _,proj_comp in ipairs(EntityGetComponent(entity_id, "ProjectileComponent") or {}) do
		ComponentSetValue2(proj_comp, "mWhoShot", shooter)
		ComponentSetValue2(proj_comp, "mShooterHerdId", herd_id) --should be fine if nil..?
	end

	for _,vel_comp in ipairs(EntityGetComponent(entity_id, "VelocityComponent") or {}) do
		ComponentSetValue2(vel_comp, "mVelocity", vel_x, vel_y)
	end

	return entity_id
end

---Shorthand for quickly getting the int value of a VSC
---@param entity_id entity_id ID of the entity
---@param variable_name string Name of the variable
---@param create_if_nil? boolean If true, a new VSC of the given name will be created if it doesn't exist
---@return int Value that matches the given VSC name
function utils.GetInternalInt(entity_id, variable_name, create_if_nil)
	local value = nil
	local vscomps = EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent")
	if vscomps ~= nil then
		for key,comp_id in pairs(vscomps) do
			local var_name = ComponentGetValue2(comp_id, "name")
			if var_name == variable_name then
				value = ComponentGetValue2(comp_id, "value_int")
			end
		end
	end

	if value == nil and create_if_nil then
		EntityAddComponent2(entity_id, "VariableStorageComponent", {
			name = variable_name,
			value_int = 0
		})
		value = 0
	end

	return value
end

---Shorthand for quickly setting a VSC's int value, or creating one if a VSC with the same name doesn't exist yet
---@param entity_id entity_id ID of the entity
---@param variable_name string Name of the variable
---@param new_value int New value of the variable (or initial value, if VSC did not exist)
function utils.SetInternalInt(entity_id, variable_name, new_value)
	local variable_found = false
	local vscomps = EntityGetComponent(entity_id, "VariableStorageComponent")
	if vscomps ~= nil then
		for key,comp_id in pairs(vscomps) do
			local var_name = ComponentGetValue2(comp_id, "name")
			if var_name == variable_name then
				ComponentSetValue2(comp_id, "value_int", new_value)
				variable_found = true
			end
		end
	end

	if not variable_found then
		EntityAddComponent2(entity_id, "VariableStorageComponent", {
			name = variable_name,
			value_int = new_value
		})
	end
end

---Shorthand for quickly getting the string value of a VSC
---@param entity_id entity_id ID of the entity
---@param variable_name string Name of the variable
---@param create_if_nil? boolean If true, a new VSC of the given name will be created if it doesn't exist
---@return string Value that matches the given VSC name
function utils.GetInternalString(entity_id, variable_name, create_if_nil)
	local value = nil
	local vscomps = EntityGetComponentIncludingDisabled(entity_id, "VariableStorageComponent")
	if vscomps ~= nil then
		for key,comp_id in pairs(vscomps) do
			local var_name = ComponentGetValue2(comp_id, "name")
			if var_name == variable_name then
				value = ComponentGetValue2(comp_id, "value_string")
			end
		end
	end

	if value == nil and create_if_nil then
		EntityAddComponent2(entity_id, "VariableStorageComponent", {
			name = variable_name,
			value_string = ""
		})
		value = ""
	end

	return value
end

---Shorthand for quickly setting a VSC's string value, or creating one if a VSC with the same name doesn't exist yet
---@param entity_id entity_id ID of the entity
---@param variable_name string Name of the variable
---@param new_value string New value of the variable (or initial value, if VSC did not exist)
function utils.SetInternalString(entity_id, variable_name, new_value)
	local variable_found = false
	local vscomps = EntityGetComponent(entity_id, "VariableStorageComponent")
	if vscomps ~= nil then
		for key,comp_id in pairs(vscomps) do
			local var_name = ComponentGetValue2(comp_id, "name")
			if var_name == variable_name then
				ComponentSetValue2(comp_id, "value_string", new_value)
				variable_found = true
			end
		end
	end

	if not variable_found then
		EntityAddComponent2(entity_id, "VariableStorageComponent", {
			name = variable_name,
			value_string = new_value
		})
	end
end

---Returns the player, polymorphed or not. Pass x, y and distance for a distance check.
---@param x number?
---@param y number?
---@param distance number?
---@returns entity_id?
function utils.GetPlayerEntity(x, y, distance)
  local tags = {"player_unit", "polymorphed_player", "polymorphed_cessation"}
	for _,tag in pairs(tags) do
		local player

		if x and y and distance then
			player = EntityGetInRadiusWithTag(x, y, distance, tag)
		else
			player = EntityGetWithTag(tag)
		end

		if #player > 0 then
			return player[1]
		end
	end

  return nil
end

---Remaps a value between (a1,b1) to (a2,b2)
---@param value int Value to remap
---@param inMin int Lower end of the input range
---@param inMax int Higher end of the input range
---@param outMin int Lower end of the output range
---@param outMax int Higher end of the output range
---@return int result The mapped value
function utils.Remap( value, inMin, inMax, outMin, outMax )
	if inMax == inMin then
		error("Input range cannot have zero length")
	end

	-- normalise the input value to a 0‑1 scale
	local t = (value - inMin) / (inMax - inMin)

	return outMin + t * (outMax - outMin)
end

--- Returns the pickup count of a specific perk
---@param perk_id string The perk's ID, i.e. "REMOVE_FOG_OF_WAR"
---@return number count The amount of times this perk was taken by the player.
function utils.GetPerkPickupCount( perk_id )
	dofile_once("data/scripts/perks/perk_list.lua")

	---@diagnostic disable-next-line: undefined-global
	local flag_name = get_perk_picked_flag_name(perk_id)
	local pickup_count = tonumber(GlobalsGetValue(flag_name .. "_PICKUP_COUNT", "0"))

	return pickup_count or 0
end

--- Triggers a lua script after a delay
---@param entity_id entity_id The entity that will hold the LuaComponent
---@param script_path string Path to the script to be executed
---@param delay int? Delay before script execution in frames (default 30)
function utils.TriggerScriptDelayed(entity_id, script_path, delay)
	delay = delay or 30
	EntityAddComponent2(entity_id, "LuaComponent", {
		script_source_file = script_path,
		execute_on_added = false,
		execute_every_n_frame = delay,
		remove_after_executed = true,
	})
end

--- Shorthand for removing all children and components that match a given tag
---@param entity_id entity_id The entity id of the entity whose children and components are to be removed
---@param tag string The tag to filter by
function utils.EntityRemoveAllByTag(entity_id, tag)
	for i,child_id in ipairs(EntityGetAllChildren(entity_id, tag) or {}) do
		if EntityHasTag(child_id, tag) then
			EntityKill(child_id)
		end
	end
	for i,comp_id in ipairs(EntityGetAllComponents(entity_id)) do
		if ComponentHasTag(comp_id, tag) then
			EntityRemoveComponent(entity_id, comp_id)
		end
	end
end

---Formats an integer as an ordinal (1st, 2nd, 3rd, 4th, etc).
---English-only, currently used only for splashes which aren't translated
---@param int integer
---@return string
function utils.EnglishOrd(int)
	local frac = int % 10
	if frac == 1 then return int.."st" end
	if frac == 2 then return int.."nd" end
	if frac == 3 then return int.."rd" end
	return int.."th"
end

---Changes an entity's HP/max HP in DamageModelComponent. Values are 1/25
---@param eid entity_id Entity's ID
---@param hp integer? New HP (if nil and max_hp is present, will keep the entity's old HP but cap it)
---@param max_hp integer? New max HP (omit to not change it)
function utils.EntitySetHp(eid, hp, max_hp)
	local dmc = EntityGetFirstComponent(eid, "DamageModelComponent")
	if not dmc then return end

	if not hp and max_hp then
		hp = math.min(tonumber(ComponentGetValue2(dmc, "hp")) or max_hp, max_hp)
	end

	if max_hp then ComponentSetValue2(dmc, "max_hp", max_hp) end
	if hp then ComponentSetValue2(dmc, "hp", hp) end
end

---Returns an entity's HP and max HP from DamageModelComponent
---@param eid entity_id Entity's ID
---@return { hp: integer, max_hp: int }? hp Entity's health; values are 1/25
function utils.EntityGetHp(eid)
	local dmc = EntityGetFirstComponent(eid, "DamageModelComponent")
	if not dmc then return end
	return {
		hp = tonumber(ComponentGetValue2(dmc, "hp")),
		max_hp = tonumber(ComponentGetValue2(dmc, "max_hp")),
	}
end

---Adds `increment` to the entity's HP in DamageModelComponent
---@param eid entity_id Entity's ID
---@param increment integer Value to add (pass negative to reduce HP instead); value is 1/25
function utils.EntityAddHp(eid, increment)
	local hp = utils.EntityGetHp(eid)
	if not hp then return end
	utils.EntitySetHp(eid, hp.hp + increment)
end

---Add an enemy `enemy` to the progress list after `after_enemy`.
---The enemy must be defined in `data/ui_gfx/animal_icons` and `data/entities/animals` (see existing enemies).
---This function simply changes the order of the custom enemy.
---
---Must be called during mod init.
function utils.AddEnemyToProgress(enemy, after_existing_enemy)
	utils.patchifile("data/ui_gfx/animal_icons/_list.txt", {
		{
			from = after_existing_enemy .. "\n",
			insert_after = enemy .. "\n",
			count = 1
		}
	})
end

---Clones a table
---@param orig table
---@param copies nil
---@return table
function utils.deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[utils.deepcopy(orig_key, copies)] = utils.deepcopy(orig_value, copies)
            end
            setmetatable(copy, utils.deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return utils
