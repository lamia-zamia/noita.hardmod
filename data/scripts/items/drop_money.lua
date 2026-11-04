dofile_once("data/scripts/lib/utilities.lua")
dofile_once("data/scripts/game_helpers.lua")

local hooks = {
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
	funcs = {},
}

for _,path in ipairs(ModLuaFileGetAppends("data/scripts/items/_drop_money.lua")) do
	dofile_once(path)(hooks)
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

local nugget_data = {}

function do_money_drop(amount_multiplier, trick_kill, damage_type_bit_field, message, attacker, drop_items)
	do return end
	local entity = GetUpdatedEntityID()
	local x, y = EntityGetTransform(entity)
	local comp_worldstate = EntityGetFirstComponent(GameGetWorldStateEntity(), "WorldStateComponent")
	if not comp_worldstate then return end

	local data = {
		comp_worldstate = comp_worldstate,
		multiplier = amount_multiplier,
		greed_curse_multiplier = 3,
		no_gold_drop = false,
		remove_timer = false,
		entity = entity,
		x = x, y = y,
		amount = 10,
		death = {
			damage_type_bit_field = damage_type_bit_field,
			message = message,
			attacker = attacker,
			drop_items = drop_items,
		},

		fix_nwt_blood_money_drops = true
	}

	for _,func in ipairs(hooks.pre_funcs) do
		func(data)
	end

	if data.no_gold_drop then return end

	data.dmc = EntityGetFirstComponent(entity, "DamageModelComponent")
	if data.dmc then
		data.health = tonumber(ComponentGetValue2(data.dmc, "max_hp")) or 0
		data.amount = math.max(data.amount, math.floor(data.health) * 100)
	end

	data.amount = data.amount * data.amount_multiplier

	for _,func in ipairs(hooks.funcs) do
		func(data)
	end

	local nuggets = {}

	local gold_entity = "data/entities/items/pickup/goldnugget_"
	local remove_timer = false
	local drop_first_10 = true

	local comp_worldstate = EntityGetFirstComponent(GameGetWorldStateEntity(), "WorldStateComponent")
	if(comp_worldstate ~= nil) then
		if(ComponentGetValue2(comp_worldstate, "perk_gold_is_forever")) then
			remove_timer = true
		end

		if(trick_kill) then
			-- if worldstate perk_trick_kills_blood_money == 1
			if(ComponentGetValue2(comp_worldstate, "perk_trick_kills_blood_money")) then
				gold_entity = "data/entities/items/pickup/bloodmoney_"
				drop_first_10 = false
			end
		end

		-- drop hp?
	end

	--- spawn first 10 gold as small nuggets
	if(drop_first_10) then
		local nugget_10_count = 0
		while data.amount >= 10 and nugget_10_count < 5 do
			local eid = load_gold_entity(gold_entity .. "10.xml", x, y-8, remove_timer)
			data.amount = data.amount - 10
			nugget_10_count = nugget_10_count + 1

			table.insert(nuggets, {eid, 6})
		end
	end
	-------

	--- NOTE(Petri): Handle extra large drops, by dropping a statue worth a lot of cheddar
	if(data.amount >= 200000 * 11) then
		local extra_money = (data.amount - (200000 * 10))
		data.amount = data.amount - extra_money

		-- clamp extra money to int32 maxish
		-- also no need to spawn rest of the dough
		if(extra_money > (2147483647 - 512)) then
			extra_money = (2147483647 - 512)
			data.amount = 0
		end

		local eid = load_gold_entity(gold_entity .. "x.xml", x, y-8, remove_timer)

		local var_comps = EntityGetComponent(eid, "VariableStorageComponent")
		if (var_comps ~= nil) then
			for i,v in ipairs(var_comps) do
				local n = ComponentGetValue2(v, "name")
				if (n == "gold_value") then
					ComponentSetValue2(v, "value_int", extra_money)
					break
				end
			end
		end

		table.insert(nuggets, {eid, 12})
	end

	---
	while data.amount >= 200000 do
		local eid = load_gold_entity(gold_entity .. "200000.xml", x, y-8, remove_timer)
		data.amount = data.amount - 200000

		table.insert(nuggets, {eid, 12})
	end

	while data.amount >= 10000 do
		local eid = load_gold_entity(gold_entity .. "10000.xml", x, y-8, remove_timer)
		data.amount = data.amount - 10000

		table.insert(nuggets, {eid, 12})
	end

	while data.amount >= 1000 do
		local eid = load_gold_entity(gold_entity .. "1000.xml", x, y-8, remove_timer)
		data.amount = data.amount - 1000

		table.insert(nuggets, {eid, 20})
	end

	while data.amount >= 200 do
		local eid = load_gold_entity(gold_entity .. "200.xml", x, y-8, remove_timer)
		data.amount = data.amount - 200

		table.insert(nuggets, {eid, 12})
	end

	while data.amount >= 50 do
		local eid = load_gold_entity(gold_entity .. "50.xml", x, y-8, remove_timer)
		data.amount = data.amount - 50

		table.insert(nuggets, {eid, 9})
	end

	while data.amount >= 10 do
		local eid = load_gold_entity(gold_entity .. "10.xml", x, y-8, remove_timer)
		data.amount = data.amount - 10

		table.insert(nuggets, {eid, 6})
	end

	if GameHasFlagRun("exploding_gold") then
		for i,v in ipairs(nuggets) do
			local eid = v[1]
			local size = tostring(v[2])

			EntityAddComponent(eid, "CollisionTriggerComponent",
			{
				width = size,
				height = size,
				required_tag = "enemy",
				timer_for_destruction = "5",
			})

			EntityAddComponent(eid, "LuaComponent",
			{
				execute_every_n_frame = "-1",
				script_collision_trigger_hit = "data/scripts/perks/gold_explosion_collision_trigger.lua"
			})
		end
	end
end

function death(damage_type_bit_field, message, attacker, drop_items)
	do_money_drop(1, false, damage_type_bit_field, message, attacker, drop_items)
end

do return end

for _,entity in ipairs(EntityGetWithTag("hardmod_blessed")) do
	for _,child in ipairs(EntityGetAllChildren(entity) or {}) do
		if EntityGetName(child) == "hardmod.enemy_perks" then
			for _,spr_comp in ipairs(EntityGetComponent(child, "SpriteComponent") or {}) do
				print(ComponentGetValue2(spr_comp, a))
			end
			break
		end
	end
end


do return end

local px,py = EntityGetTransform(99) --player_id
local x,y = EntityGetTransform(GameGetWorldStateEntity())
for _,entity in ipairs(EntityGetInRadius(x, y, 10)) do
	local root = EntityGetRootEntity(entity)
	if EntityHasTag(root, "hardmod_blessed") then
		EntitySetTransform(root, px, py)
		print(("eid: %s\n  name: [%s]\n  root: %s\n  root name: [%s]"):format(entity, EntityGetName(entity), root, EntityGetName(root)))
	end
end