dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/game_helpers.lua")

---@class nugget
---@field eid entity_id? entity id of the nugget available in post_processing hook
---@field path string filepath to target entity file
---@field value number value of this nugget
---@field heal_amount number? heal factor of this nugget
---@field x number? relative x position to spawn at, default 0
---@field y number? relative y position to spawn at, default 0
---@field func function? optional function to run after spawning this nugget
---@field group string? groupname assigned to it

local hooks = {} ---@type drop_money_hooks

hooks = { ---@class drop_money_hooks
	legacy_nwt_blood_money_drops = true,


	pre_funcs = {
		{
			id = "trailer_mode_disable_gold",
			func = function(data)
				data.no_gold_drop = GameGetIsTrailerModeEnabled()
			end,
		},
		{
			id = "varcomp_disable_gold",
			func = function(data)
				data.no_gold_drop = EntityGetFirstComponent(data.entity, "VariableStorageComponent", "no_gold_drop")
			end,
		},
		{
			id = "greed_curse_multiplier",
			func = function(data)
				if GameHasFlagRun("greed_curse") and not GameHasFlagRun("greed_curse_gone") then
					data.multiplier = data.multiplier * 3
				end
			end,
		},
	},
	funcs = {
		{
			id = "legacy_nwt_blood_money_drop",
			func = function(data) ---@param data gold_drop_data
				if not hooks.legacy_nwt_blood_money_drops then return end

				local blood_money_chance = data.multiplier * data.blood_money_chance
				if Random(1, 100) <= blood_money_chance then
					data.nuggets[#data.nuggets+1] = hooks.clone_table(hooks.nuggets_indexed.blood[50])
					data.amount = data.amount - 50
				end
			end
		},
		{
			id = "trick_blood_money",
			func = function(data)
				if data.trick_kill and ComponentGetValue2(data.comp_worldstate, "perk_trick_kills_blood_money") then
					data.blood_money_chance = 100
				end
			end
		},
	},
	pre_calc = {
		{
			id = "cap_drop_money",
			func = function(data)
				if data.amount >= 200000 * 11 then
					local extra_money = (data.amount - (200000 * 10))
					data.amount = data.amount - extra_money

					-- clamp extra money to int32 maxish
					-- also no need to spawn rest of the dough
					if extra_money > (2147483647 - 512) then
						extra_money = (2147483647 - 512)
						data.amount = 0
					end

					data.nuggets[#data.nuggets+1] = {
						path = "data/entities/items/pickup/goldnugget_x.xml",
						func = function(self, eid)
							for i,v in ipairs(EntityGetComponent(eid, "VariableStorageComponent") or {}) do
								local n = ComponentGetValue2(v, "name")
								if n == "gold_value" then
									ComponentSetValue2(v, "value_int", extra_money)
									break
								end
							end
						end
					}
				end
			end
		},
		{
			id = "priority_nuggets",
			func = function(data)
				local target_type = data.target_gold_group
				if hooks.nuggets_indexed[target_type][10] and
					not (data.trick_kill and ComponentGetValue2(data.comp_worldstate, "perk_trick_kills_blood_money")) then
					for _=1, 5 do
						if data.amount < 10 then break end
						data.amount = data.amount-10
						data.nuggets[#data.nuggets+1] = hooks.clone_table(hooks.nuggets_indexed[target_type][10])
					end
				end
			end
		},
	},
	pre_processing = {
		{
			id = "improved_blood_money_chance",
			func = function(data) ---@param data gold_drop_data
				if hooks.legacy_nwt_blood_money_drops then return end

				if data.blood_money_chance > 0 then
					for _,nugget in ipairs(data.nuggets) do
						local chance = data.blood_money_chance * .01
						local rnd = Random()
						if nugget.group == "gold" and rnd <= chance then
							nugget.path = hooks.nuggets_indexed.blood[nugget.value].path or nugget.path
						end
					end
				end
			end
		}
	},
	post_processing = {
		{
			id = "remove_timer",
			func = function(data)
				if ComponentGetValue2(data.comp_worldstate, "perk_gold_is_forever") then
					for _,nugget in ipairs(data.nuggets) do
						for _,lifetime_comp in
						ipairs(EntityGetComponent(nugget.eid, "LifetimeComponent") or {}) do
							EntityRemoveComponent(nugget.eid, lifetime_comp)
						end
					end
				end
			end
		},
		{
			id = "exploding_gold",
			func = function(data)
				if GameHasFlagRun("exploding_gold") then
					local explosion_size_values = {
						{10, 6},
						{50, 9},
						{200, 12},
						{1000, 20},
						{10000, 12},
						{200000, 12},
					}
					for i,nugget in ipairs(data.nuggets) do
						local value = nugget.value
						local size = 12
						for _,vals in ipairs(explosion_size_values) do
							if value <= vals[1] then
								size = vals[2]
								break
							end
						end

						EntityAddComponent2(nugget.eid, "CollisionTriggerComponent", {
							width = size,
							height = size,
							required_tag = "enemy",
							timer_for_destruction = 5,
						})

						EntityAddComponent2(nugget.eid, "LuaComponent", {
							execute_every_n_frame = -1,
							script_collision_trigger_hit = "data/scripts/perks/gold_explosion_collision_trigger.lua"
						})
					end
				end
			end
		}
	},

	nuggets = {
		gold = { ---@type nugget[]
			{
				path = "data/entities/items/pickup/goldnugget_200000.xml",
				value = 200000,
			},
			{
				path = "data/entities/items/pickup/goldnugget_10000.xml",
				value = 10000,
			},
			{
				path = "data/entities/items/pickup/goldnugget_1000.xml",
				value = 1000,
			},
			{
				path = "data/entities/items/pickup/goldnugget_200.xml",
				value = 200,
			},
			{
				path = "data/entities/items/pickup/goldnugget_50.xml",
				value = 50,
			},
			{
				path = "data/entities/items/pickup/goldnugget_10.xml",
				value = 10,
			},
		},
		blood = {
			{
				path = "data/entities/items/pickup/bloodmoney_200000.xml",
				value = 200000,
			},
			{
				path = "data/entities/items/pickup/bloodmoney_10000.xml",
				value = 10000,
			},
			{
				path = "data/entities/items/pickup/bloodmoney_1000.xml",
				value = 1000,
			},
			{
				path = "data/entities/items/pickup/bloodmoney_200.xml",
				value = 200,
			},
			{
				path = "data/entities/items/pickup/bloodmoney_50.xml",
				value = 50,
			},
			{
				path = "data/entities/items/pickup/bloodmoney_10.xml",
				value = 10,
			},
		},
	},
	nuggets_indexed = {},

	---Clones a table
	---@param orig table
	---@param copies nil
	---@return table
	clone_table = function(orig, copies)
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
					copy[hooks.clone_table(orig_key, copies)] = hooks.clone_table(orig_value, copies)
				end
				setmetatable(copy, hooks.clone_table(getmetatable(orig), copies))
			end
		else -- number, string, boolean, etc
			copy = orig
		end
		return copy
	end,
}

for _,path in ipairs(ModLuaFileGetAppends("data/scripts/items/__drop_money.lua")) do
	if ModDoesFileExist(path) then
		dofile_once(path)(hooks)
	else
		print("Warning!! drop_money.lua append " .. path .. " not found!!")
	end
end

local function_tables = {
	"pre_funcs",
	"funcs",
}
for _,key in ipairs(function_tables) do
	for i,target in ipairs(hooks[key]) do
		if type(target) == "function" then hooks[key][i] = {
			func = target
		} end
	end
end

for key,list in pairs(hooks.nuggets) do --order nuggets from most to least (ignore nuggets of same value)
	table.sort(list, function(a, b)
		return (a.value or 0) > (b.value or 0)
	end)

	hooks.nuggets_indexed[key] = hooks.nuggets_indexed[key] or {}
	for _,nugget in ipairs(list) do
		nugget.group = key
		hooks.nuggets_indexed[key][nugget.value] = nugget
	end
end

---@diagnostic disable-next-line: lowercase-global
function do_money_drop(amount_multiplier, trick_kill, damage_type_bit_field, message, attacker, drop_items)
	local entity = GetUpdatedEntityID()
	local x, y = EntityGetTransform(entity)
	local comp_worldstate = EntityGetFirstComponent(GameGetWorldStateEntity(), "WorldStateComponent")
	if not comp_worldstate then return end
	SetRandomSeed(x + entity, y - entity)

	local data = { ---@class gold_drop_data
		comp_worldstate = comp_worldstate,
		trick_kill = trick_kill,
		blood_money_chance = ComponentGetValue2(comp_worldstate, "perk_hp_drop_chance"),
		multiplier = amount_multiplier,
		target_gold_group = "gold",
		greed_curse_multiplier = 3,
		minimum_amount = 10,
		no_gold_drop = false,
		entity = entity,
		x = x, y = y,
		amount = 10,
		nuggets = {}, ---@type nugget[]
		death = {
			damage_type_bit_field = damage_type_bit_field,
			message = message,
			attacker = attacker,
			drop_items = drop_items,
		},
	}


	for _,v in ipairs(hooks.pre_funcs) do
		v.func(data)
	end

	if data.no_gold_drop then return end

	data.dmc = EntityGetFirstComponent(entity, "DamageModelComponent")
	if data.dmc then
		data.health = tonumber(ComponentGetValue2(data.dmc, "max_hp")) or 0
		data.amount = math.max(data.amount, math.floor(data.health) * 10)
	end

	data.amount = math.max(data.minimum_amount, data.amount * data.multiplier)


	for _,v in ipairs(hooks.funcs) do
		v.func(data)
	end


	for _,v in ipairs(hooks.pre_calc) do
		v.func(data)
	end

	data.amount = math.max(0, data.amount)
	for _,nugget_data in ipairs(hooks.nuggets[data.target_gold_group]) do
		local nugget_value = nugget_data.value
		local number = math.floor(data.amount/nugget_value)
		for _=1, number do
			data.nuggets[#data.nuggets+1] = hooks.clone_table(nugget_data)
		end
		data.amount = data.amount % nugget_value
	end

	for _,v in ipairs(hooks.pre_processing) do
		v.func(data)
	end

	for _,nugget in ipairs(data.nuggets) do
		local eid = EntityLoad(nugget.path, x + (nugget.x or 0), y + (nugget.y or 0))
		nugget.eid = eid
		local found_healing,found_money = not nugget.heal_amount,nil
		for _,varcomp in ipairs(EntityGetComponent(eid, "VariableStorageComponent") or {}) do
			local name = ComponentGetValue2(varcomp, "name")
			if name == "gold_value" then
				found_money = true
				ComponentSetValue2(varcomp, "value_int", nugget.value)
			elseif name == "hp_value" and nugget.heal_amount then
				found_healing = true
				ComponentSetValue2(varcomp, "value_float", nugget.heal_amount)
			end
			if found_money and found_healing then break end
		end
		if nugget.func then nugget.func(eid, nugget, data) end
	end

	for _,v in ipairs(hooks.post_processing) do
		v.func(data)
	end
end

function death(damage_type_bit_field, message, attacker, drop_items)
	do_money_drop(1, false, damage_type_bit_field, message, attacker, drop_items)
end
