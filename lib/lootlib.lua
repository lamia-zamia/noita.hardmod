--[[
  ###########################
  ##  Noita Loot Lib v0.2  ##
  ###########################

  This library lets you extend vanilla loot tables (such as chests)
  and create custom loot tables that can be easily extended by other mods.

  Copyright (c) 2026 yui.dev
  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]

---@diagnostic disable: lowercase-global,undefined-global

---@alias LootTable WeightedLootItem[]

---@alias LootNumber
---|number Exact number
---|fun(ctx: LootContext): LootNumber Number from a function
---|{a:LootNumber, b: LootNumber, each?: LootNumber, is_float?: boolean} Random range from a to b, with an optional multiplier (each). Set `is_float` to use `Randomf` instead
---|LootVariable Value of the variable

---@alias LootChance
---|number Matches if `Random(0, 100) <= number`
---|{a?: number, b?: number} Matches if `a <= Random(0, 100) <= b`. (a=0, b=100 by default)

---@alias LootVariable
---|'"rolls"' Amount of rolls left to do
---|'"rolls_done"' Amount of rolls that have already been done
---|'"pos_x"' X position where to spawn the loot
---|'"pos_y"' Y position where to spawn the loot
---|'"rand_x"' X position for PRNG
---|'"rand_y"' Y position for PRNG
---|'"bad_rolls"' Amount of "bad" rolls that have occurred so far (`is_bad`)
---|'"gold"' Amount of gold to spawn at the end
---|string Any arbitrary variable for your use

---[[
---@class LootPredicate
---@field func (fun(ctx: LootContext): boolean)? Custom check with a function
---@field flag_persistent string? Check if a player has a persistent flag set
---@field flag_run string? Check if the player has a run flag set
---@field greed_curse boolean? Set to `true` to check if the player has the greed curse, and `false` to check if the player doesn't have it
---]]

---[[
---@class BaseLootItem
---@field label string? Optional label, has no functionality but useful for patching loot tables from other mods
---@field func (fun(ctx: LootContext): BaseLootItem?)? Custom drop function
---@field check LootPredicate? Optional condition. Runs the item from `success` if matches, and from `fail` if it doesn't. The current item runs regardless of the result.
---@field success BaseLootItem? This will run if the check in `check` succeeds
---@field fail BaseLootItem? This will run if the check in `check` fails
---@field do_all BaseLootItem[]? Run all these items sequentially
---@field pick_weighted WeightedLootItem[]? Run a single item from a weighted list
---@field pick_chance ChanceLootItem[]? Run a single item from a list with chances
---@field pick_chance_all ChanceLootItem[]? Run all items from a list with chances
---@field pick_chance_at_least_one boolean? Ensures `pick_chance` or `pick_chance_all` picks at least a single random item (if no chances matched, pick an entirely random item)
---@field pick_random BaseLootItem[]? Run a random item from a list
---@field entity string? Entity file to spawn
---@field entity_func fun(eid: entity_id)? This will be called after `entity` is summoned
---@field offset_x LootNumber? X offest to add to the spawned entity
---@field offset_y LootNumber? Y offest to add to the spawned entity
---@field spawn_random_cards LootNumber? Spawn [n] random cards
---@field card_filter (fun(card: any): boolean)? Filter for spawn_random_cards. Return false to disallow the card from spawning
---@field is_bad boolean? Mark the chest drop as "bad" (will summon chest_effect_bad.xml on open instead of chest_effect.xml)
---@field var LootVariable? Variable to modify
---@field set LootNumber? Number to set the specified variable to (`var`)
---@field add LootNumber? Number to add to the specified variable (`var`)
---@field sub LootNumber? Number to subtract from the specified variable (`var`)
---@field mul LootNumber? Number to multiply the specified variable by (`var`)
---@field div LootNumber? Number to divide the specified variable by (`var`)
---]]

---[[
---@class WeightedLootItem:BaseLootItem
---@field weight number Random weight
---]]

---[[
---@class ChanceLootItem:BaseLootItem
---@field chance LootChance Random chance to match
---]]

---[[
---@class LootContext
---@field entities { file: string, x: number, y: number, callback?: fun(eid: entity_id), is_gold?: boolean }[] List of entities and their positions to spawn
---@field entity_id entity_id? Chest's entity ID
---@field greed_curse boolean Whether the greed curse is active
---@field gold_is_forever boolean Whether the player has the Gold is Forever perk
---@field vars table<LootVariable, number> Variables
---]]

---@alias LootItem BaseLootItem | WeightedLootItem | ChanceLootItem

---@alias LootTableName
---|"chest_random"
---|"chest_random_super" Wrapper containing either the sampo drop or chest_random_super_base
---|"chest_random_super_base" Edit this instead of chest_random_super
---|"misc_items" Random item (runestones, die, kuu, etc) dropped by chests and utility boxes; everything has weight 1 by default
---|"utility_box"
---|string
---@alias LootHookFunc fun(ctx: LootContext, tbl: LootTable, table_name: LootTableName)

--------------------------------

if not actions then dofile_once("data/scripts/gun/gun_actions.lua") end

--------------------------------

LOOTLIB_DATA = LOOTLIB_DATA or {
  patching = false,
  patched = false,
  ---@type {[string]: LootTable}
  tables = {},
  ---@type {[string]: fun(ctx: LootContext, value: any, item: LootItem)}
  handlers = {},
  ---@type fun()[]
  patch_end_hooks = {},
  ---@type LootHookFunc[]
  chest_pre_open_hooks = {},
  ---@type LootHookFunc[]
  chest_post_open_hooks = {},
  ---@type fun(entity: entity_id)?
  orig_chest_on_open = nil,

  config = {
    chest_script_loot_table_names = {
      ["data/scripts/items/chest_random.lua"] = "chest_random",
      ["data/scripts/items/chest_random_super.lua"] = "chest_random_super",
      ["data/scripts/items/utility_box.lua"] = "utility_box",
    }
  }
}

---@class lootlib
local lootlib = {
  handlers = LOOTLIB_DATA.handlers,
  config = LOOTLIB_DATA.config,
  ---@type {[string]: LootTable}
  default_loot_tables = {},
}

--------------------------------
---      Main functions      ---
--------------------------------

---Create a loot context to use for generating loot tables
---@param pos_x number? X position where to spawn the loot
---@param pos_y number? Y position where to spawn the loot
---@param entity_id integer? Chest's entity ID
---@param rand_x number? X position for PRNG
---@param rand_y number? Y position for PRNG
---@param rolls number? Initial amount of rolls to do (defaults to 1)
---@return LootContext
function lootlib.create_context(pos_x, pos_y, rand_x, rand_y, entity_id, rolls)
  local gold_is_forever = false
  local wsc = EntityGetFirstComponent(GameGetWorldStateEntity(), "WorldStateComponent")
  if wsc ~= nil and ComponentGetValue2(wsc, "perk_gold_is_forever") then
    gold_is_forever = true
  end

  return {
    entities = {},
    greed_curse = GameHasFlagRun("greed_curse") and not GameHasFlagRun("greed_curse_gone"),
    gold_is_forever = gold_is_forever,
    entity_id = entity_id,
    vars = {
      pos_x = pos_x or 0,
      pos_y = pos_y or 0,
      rand_x = rand_x or pos_x or 0,
      rand_y = rand_y or pos_y or 0,
      rolls = rolls or 1,
      rolls_done = 0,
      bad_rolls = 0,
      gold = 0,
    }
  }
end

---Generate and spawn a loot table
---@param tbl LootTable
---@param ctx LootContext
---@return LootContext
function lootlib.generate(tbl, ctx)
  lootlib.roll_loot(tbl, ctx)
  lootlib.spawn_loot(ctx)
  return ctx
end

---Generate a loot table. This might still spawn some things depending on the loot table.
---
---Call `lootlib.spawn_loot` to spawn the generated loot, or `lootlib.generate` instead if you just want to do both at once
---@param tbl LootTable
---@param ctx LootContext
---@return LootContext
function lootlib.roll_loot(tbl, ctx)
  SetRandomSeed(ctx.vars.rand_x, ctx.vars.rand_y)

  while ctx.vars.rolls > 0 do
    ctx.vars.rolls = ctx.vars.rolls - 1
    ctx.vars.rolls_done = ctx.vars.rolls_done + 1
    lootlib.run_item(ctx, { pick_weighted = tbl })
  end

  return ctx
end

---Spawn the generated loot from a loot table (from `lootlib.roll_loot`)
---@param ctx LootContext
function lootlib.spawn_loot(ctx)
  if ctx.vars.gold > 0 then
    lootlib.spawn_gold(ctx, ctx.vars.gold)
  end

  for _,entity in pairs(ctx.entities) do
    local eid = EntityLoad(entity.file, entity.x, entity.y)

    local item_comp = EntityGetFirstComponent( eid, "ItemComponent" )
    if item_comp and ComponentGetValue2(item_comp, "auto_pickup") then
      ComponentSetValue2(item_comp, "next_frame_pickable", GameGetFrameNum() + 30)
    end

    if entity.is_gold then
      if ctx.gold_is_forever then
        local lifetime_comp = EntityGetComponent(eid, "LifetimeComponent")
        if lifetime_comp then
          for _,comp in pairs(lifetime_comp) do EntityRemoveComponent(eid, comp) end
        end
      end

      EntityAddTag(eid, "lootlib_chest_gold")
    end

	if entity.callback then
		entity.callback(eid)
	end
  end
end

---@param ctx LootContext
---@param item LootItem?
---@return nil
function lootlib.run_item(ctx, item)
  if type(item) ~= "table" then return end

  for key,handler in pairs(lootlib.handlers) do
    local val = item[key]
    if val ~= nil then
      handler(ctx, val, item)
    end
  end
end

---@param ctx LootContext
---@param num LootNumber
---@param default LootNumber?
---@return number
function lootlib.get_value(ctx, num, default)
  if num == nil then num = default or 0 end
  if type(num) == "table" then
    local a = lootlib.get_value(ctx, num.a)
    local b = lootlib.get_value(ctx, num.b)
    local each = lootlib.get_value(ctx, num.each, 1)

    if num.is_float then
      return Randomf(a, b) * each
    else
      return Random(a, b) * each
    end
  elseif type(num) == "string" then
    return ctx.vars[num] or 0
  elseif type(num) == "function" then
    return lootlib.get_value(ctx, num(ctx))
  else
    return num
  end
end

---@param rnd number
---@param chance LootChance
---@return boolean
function lootlib.chance_matches(rnd, chance)
  if type(chance) == "table" then
    return rnd >= (chance.a or 0) and rnd <= (chance.b or 100)
  else
    return rnd <= chance
  end
end

---@param x number
---@param y number
---@param filter (fun(card: any): boolean)?
---@return entity_id?
function lootlib.spawn_random_card(x, y, filter)
  local found = nil

  for _=1,999 do
    ---@diagnostic disable-next-line: undefined-global
    local card = actions[Random(1, #actions)]

    if
      not card.spawn_requires_flag
      or HasFlagPersistent(card.spawn_requires_flag)
      and card.spawn_probability ~= "0"
    then
      if not filter or filter(card) then
        found = card
        break
      end
    end
  end

  if found then
    return CreateItemActionEntity(string.lower(found.id), x, y)
  end
end

---@param ctx LootContext
---@param gold number
function lootlib.spawn_gold(ctx, gold)
  local spawned = 0
  local gold_nuggets = {
    { "data/entities/items/pickup/goldnugget_200000.xml", 200000 },
    { "data/entities/items/pickup/goldnugget_10000.xml", 10000 },
    { "data/entities/items/pickup/goldnugget_1000.xml", 1000 },
    { "data/entities/items/pickup/goldnugget_200.xml", 200 },
    { "data/entities/items/pickup/goldnugget_50.xml", 50 },
    { "data/entities/items/pickup/goldnugget_10.xml", 10 },
  }

  while gold > 10 and spawned < 500 do
    local entity = nil

    for _,nugget in pairs(gold_nuggets) do
      if gold >= nugget[2] then
        entity = nugget[1]
        gold = gold - nugget[2]
        break
      end
    end

    if not entity then break end
    
    table.insert(ctx.entities, {
      file = entity,
      x = ctx.vars.pos_x,
      y = ctx.vars.pos_y,
      is_gold = true
    })

    spawned = spawned + 1
  end
end

--------------------------------
---         Handlers         ---
--------------------------------

---@param check LootPredicate
function lootlib.handlers.check(ctx, check, item)
  local valid = true

  if
    (check.func and not check.func(ctx))
    or (check.flag_persistent and not HasFlagPersistent(check.flag_persistent))
    or (check.flag_run and not GameHasFlagRun(check.flag_run))
    or (check.greed_curse and ctx.greed_curse ~= check.greed_curse)
  then
    valid = false
  end

  if valid then
    lootlib.run_item(ctx, item.success)
  else
    lootlib.run_item(ctx, item.fail)
  end
end

---@param func fun(ctx: LootContext): BaseLootItem?
function lootlib.handlers.func(ctx, func)
  lootlib.run_item(ctx, func(ctx))
end

---@param tbl WeightedLootItem[]
function lootlib.handlers.pick_weighted(ctx, tbl)
  local total = 0
  for _,item in pairs(tbl) do
    total = total + item.weight
  end

  local threshold = Random() * total
  local item = tbl[#tbl]
  total = 0

  for _,it in pairs(tbl) do
    total = total + it.weight
    if total > threshold then
      item = it
      break
    end
  end

  lootlib.run_item(ctx, item)
end

---@param tbl ChanceLootItem[]
function lootlib.handlers.pick_chance(ctx, tbl, item)
  local rnd = Random(0, 100)
  for _,it in pairs(tbl) do
    if lootlib.chance_matches(rnd, it.chance) then
      lootlib.run_item(ctx, it)
      return
    end
  end

  if item.pick_chance_at_least_one then
    lootlib.handlers.pick_random(ctx, tbl, item)
  end
end

---@param tbl ChanceLootItem[]
function lootlib.handlers.pick_chance_all(ctx, tbl, item)
  local picked = false
  for _,it in pairs(tbl) do
    if lootlib.chance_matches(Random(0, 100), it.chance) then
      lootlib.run_item(ctx, it)
      picked = true
    end
  end

  if not picked and item.pick_chance_at_least_one then
    lootlib.handlers.pick_random(ctx, tbl, item)
  end
end

---@param tbl BaseLootItem[]
function lootlib.handlers.pick_random(ctx, tbl)
  lootlib.run_item(ctx, tbl[Random(1, #tbl)])
end

---@param tbl BaseLootItem[]
function lootlib.handlers.do_all(ctx, tbl)
  for _,it in pairs(tbl) do
    lootlib.run_item(ctx, it)
  end
end

---@param var LootVariable
function lootlib.handlers.var(ctx, var, item)
  local value = ctx.vars[var] or 0

  if item.set then value = lootlib.get_value(ctx, item.set) end
  if item.add then value = value + lootlib.get_value(ctx, item.add) end
  if item.sub then value = value - lootlib.get_value(ctx, item.sub) end
  if item.mul then value = value * lootlib.get_value(ctx, item.mul) end
  if item.div then value = value / lootlib.get_value(ctx, item.div) end

  ctx.vars[var] = value
end

---@param entity string
function lootlib.handlers.entity(ctx, entity, item)
  local x = ctx.vars.pos_x + lootlib.get_value(ctx, item.offset_x, { a=-10, b=10 })
  local y = ctx.vars.pos_y + lootlib.get_value(ctx, item.offset_y, { a=-9, b=1 })

  table.insert(ctx.entities, {
    file = entity,
	callback = item.entity_func,
    x = x, y = y
  })
end

---@param amount LootNumber
function lootlib.handlers.spawn_random_cards(ctx, amount, item)
  amount = lootlib.get_value(ctx, amount)
  for i=1,amount do
    lootlib.spawn_random_card(ctx.vars.pos_x + (i - (amount / 2)) * 8, ctx.vars.pos_y + Random(-9, 1), item.card_filter)
  end
end

function lootlib.handlers.is_bad(ctx)
  ctx.vars.bad_rolls = ctx.vars.bad_rolls + 1
end

--------------------------------
---         Patching         ---
--------------------------------

local patch_file = "data/_lootlib_patch_init.lua"
local function make_patch_file()
  if not ModDoesFileExist(patch_file) then
    ModTextFileSetContent(patch_file, "--")
  end
end

---Add a patch script for editing loot tables.
---
---You should modify loot tables inside of patch scripts, so that other mods can access the loot tables too.
---
---This file will be ran for every separate context that needs to generate loot tables.
---@param script string Path to the script
function lootlib.add_patch_script(script)
  make_patch_file()
  ModLuaFileAppend(patch_file, script)
end

---Get a list of all added patch scripts
---@return string[]
function lootlib.get_patch_scripts()
  make_patch_file()
  return ModLuaFileGetAppends(patch_file)
end

---Override a list of patch scripts
---@param scripts string[]
function lootlib.set_patch_scripts(scripts)
  make_patch_file()
  ModLuaFileSetAppends(patch_file, scripts)
end

---The provided function will be called after all patch scripts have finished running
---
---Available only inside of a patching script
---@param cb fun()
function lootlib.on_patching_end(cb)
  if not LOOTLIB_DATA.patching then return end
  table.insert(LOOTLIB_DATA.patch_end_hooks, cb)
end

function lootlib.load_patches()
  if LOOTLIB_DATA.patched or LOOTLIB_DATA.patching then return end

  for key,tbl in pairs(lootlib.default_loot_tables) do
    if LOOTLIB_DATA.tables[key] == nil then
      LOOTLIB_DATA.tables[key] = tbl
    end
  end

  local scripts = lootlib.get_patch_scripts()
  LOOTLIB_DATA.patching = true

  for _,script in pairs(scripts) do
    if ModDoesFileExist(script) then
      dofile_once(script)
    else
      print_error("lootlib.load_patches(): file does not exist: " .. script)
    end
  end

  for _,hook in pairs(LOOTLIB_DATA.patch_end_hooks) do
    hook()
  end

  LOOTLIB_DATA.patch_end_hooks = nil
  LOOTLIB_DATA.patched = true
  LOOTLIB_DATA.patching = false
end

---Returns a loot table by the provided name.
---
---You can edit the loot table inside of patch scripts (`lootlib.add_patch_script`)
---
---Use `lootlib.generate` combined with `lootlib.create_context` to generate the loot table.
---@param name LootTableName
---@return LootTable
function lootlib.get_loot_table(name)
  lootlib.load_patches()

  local tbl = LOOTLIB_DATA.tables[name]
  if tbl == nil then
    print_error("lootlib.get_loot_table(" .. name .. "): table does not exist")
    return {}
  end

  return tbl
end

---Creates a new loot table, or overrides an existing one.
---
---Only available inside of patch scripts (`lootlib.add_patch_script`).
---
---If you want to change an existing loot table, please consider patching it instead of completely overriding.
---@param name string Loot table name
---@param tbl LootTable
function lootlib.set_loot_table(name, tbl)
  if not LOOTLIB_DATA.patching then
    print_error("lootlib.set_loot_table() called outside of a patch script")
    return
  end

  LOOTLIB_DATA.tables[name] = tbl
end

---Adds all items from `tbl` to the loot table.
---
---Only available inside of patch scripts (`lootlib.add_patch_script`).
---@param name_or_table LootTableName|LootTable Loot table or its name
---@param tbl LootTable
function lootlib.extend_loot_table(name_or_table, tbl)
  if not LOOTLIB_DATA.patching then
    print_error("lootlib.extend_loot_table() called outside of a patch script")
    return
  end

  local orig = name_or_table
  if type(orig) == "string" then orig = lootlib.get_loot_table(orig) end

  for _,val in pairs(tbl) do
    table.insert(orig, val)
  end
end

---Returns a table of all loot tables
---@return {[string]: LootTable}
function lootlib.get_all_loot_tables()
  lootlib.load_patches()
  return LOOTLIB_DATA.tables
end

---Get a labeled item from a loot table/array of loot items
---@param tbl LootItem[]
---@param label string
---@param recursive boolean? Whether or not to recurse (true by default)
---@return LootItem?
function lootlib.get_label(tbl, label, recursive)
  if recursive == nil then recursive = true end

  for _,item in pairs(tbl) do
    if type(item) ~= "table" then
      goto continue
    end

    if item.label == label then
      return item
    end

    if recursive then
      for _,value in pairs(item) do
        if type(value) == "table" then
          local it = lootlib.get_label(value, label)
          if it then return it end
        end
      end
    end

    ::continue::
  end
end

--------------------------------
---      Chest patches       ---
--------------------------------

---Add mod appends to vanilla chests
---@param lib_path string Path to lootlib
function lootlib.init_patches(lib_path)
  if not ModDoesFileExist(lib_path) then
    error("Invalid library path " .. lib_path)
  end

  for file,_ in pairs(lootlib.config.chest_script_loot_table_names) do
    if not ModDoesFileExist(file) then
      print_error("Invalid chest script path " .. file)
    else
      ModLuaFileAppend(file, lib_path)
    end
  end
end

---The provided function will be called right before a chest opens.
---You can edit the passed context and loot table.
---
---Keep in mind changes to the loot table stay, it is not a copy.
---@param cb LootHookFunc
function lootlib.on_chest_pre_open(cb)
  table.insert(LOOTLIB_DATA.chest_pre_open_hooks, cb)
end

---The provided function will be called right after a chest's loot table is generated, but before it is spawned.
---
---You can modify the passed context to add more gold or entities to spawn.
---@param cb LootHookFunc
function lootlib.on_chest_post_open(cb)
  table.insert(LOOTLIB_DATA.chest_post_open_hooks, cb)
end

local function chest_on_open_patch(entity)
  local comps = EntityGetComponent(entity, "LuaComponent")
  local loot_table_name = nil

  if comps then
    for _,comp in pairs(comps) do
      local script = ComponentGetValue2(comp, "script_item_picked_up")
      local name = lootlib.config.chest_script_loot_table_names[script]

      if name then
        loot_table_name = name
        break
      end
    end
  end

  if not loot_table_name then
    return LOOTLIB_DATA.orig_chest_on_open(entity)
  end

  local x, y = EntityGetTransform(entity)
  local rx, ry = x, y

  local pos = EntityGetFirstComponent(entity, "PositionSeedComponent")
  if pos then
    rx = tonumber(ComponentGetValue2(pos, "pos_x")) or rx
    ry = tonumber(ComponentGetValue2(pos, "pos_y")) or ry
  end

  rx = rx + 509.7
  ry = ry + 683.1

  local ctx = lootlib.create_context(x, y, rx, ry, entity, 1)
  local loot_table = lootlib.get_loot_table(loot_table_name)

  for _,hook in pairs(LOOTLIB_DATA.chest_pre_open_hooks) do
	SetRandomSeed(ctx.vars.rand_x, ctx.vars.rand_y)
    hook(ctx, loot_table, loot_table_name)
  end

  SetRandomSeed(ctx.vars.rand_x, ctx.vars.rand_y)

  lootlib.roll_loot(loot_table, ctx)
  
  for _,hook in pairs(LOOTLIB_DATA.chest_post_open_hooks) do
    hook(ctx, loot_table, loot_table_name)
  end

  lootlib.spawn_loot(ctx)

  if ctx.vars.bad_rolls > 0 then
    EntityLoad("data/entities/particles/image_emitters/chest_effect_bad.xml", x, y)
  else
    EntityLoad("data/entities/particles/image_emitters/chest_effect.xml", x, y)
  end
end

if on_open and not LOOTLIB_DATA.orig_chest_on_open then
  LOOTLIB_DATA.orig_chest_on_open = on_open
  on_open = chest_on_open_patch
end

--------------------------------
---   Vanilla loot tables    ---
--------------------------------

lootlib.default_loot_tables.misc_items = {
  { weight = 1, entity = "data/entities/items/pickup/safe_haven.xml" },
  { weight = 1, entity = "data/entities/items/pickup/moon.xml" },
  { weight = 1, entity = "data/entities/items/pickup/thunderstone.xml" },
  { weight = 1, entity = "data/entities/items/pickup/evil_eye.xml" },
  { weight = 1, entity = "data/entities/items/pickup/brimstone.xml" },
  {
    label = "die",
    weight = 1,
    check = { flag_persistent = "card_unlocked_duplicate" },
    success = {
      check = { greed_curse = true },
      success = { entity = "data/entities/items/pickup/physics_greed_die.xml" },
      fail = { entity = "data/entities/items/pickup/physics_die.xml" }
    },
    fail = { entity = "data/entities/items/pickup/potion.xml" }
  },
  {
    label = "runestone",
    weight = 1,
    pick_random = {
      { entity = "data/entities/items/pickup/runestones/runestone_laser.xml" },
      { entity = "data/entities/items/pickup/runestones/runestone_fireball.xml" },
      { entity = "data/entities/items/pickup/runestones/runestone_lava.xml" },
      { entity = "data/entities/items/pickup/runestones/runestone_slow.xml" },
      { entity = "data/entities/items/pickup/runestones/runestone_null.xml" },
      { entity = "data/entities/items/pickup/runestones/runestone_disc.xml" },
      { entity = "data/entities/items/pickup/runestones/runestone_metal.xml" },
    }
  },
  {
    label = "gold_orb",
    weight = 1,
    check = { greed_curse = true },
    success = { entity = "data/entities/items/pickup/physics_gold_orb_greed.xml" },
    fail = { entity = "data/entities/items/pickup/physics_gold_orb.xml" }
  }
}

lootlib.default_loot_tables.chest_random = {
  { label = "bomb", weight = 7, is_bad = true, entity = "data/entities/projectiles/bomb_small.xml" },
  {
    label = "gold",
    weight = 33,
    do_all = {
      {
        pick_weighted = {
          { weight = 80, var = "gold", add = 70 },
          { weight = 15, var = "gold", add = 100 },
          { weight = 5, var = "gold", add = 200 }
        }
      },
      {
        pick_weighted = {
          { weight = 50, var = "gold", add = 50 },
          { weight = 46, var = "gold", add = 200 },
          { weight = 4, var = "gold", add = 1000 },
          {
            weight = 1,
            pick_chance_all = {
              { chance = 100, var = "gold", add = { a=1, b=3, each=50 } },
              { chance = 49, var = "gold", add = { a=1, b=3, each=200 } },
              { chance = 19, var = "gold", add = { a=1, b=3, each=1000 } },
            }
          },
        }
      }
    }
  },
  {
    label = "potion",
    weight = 10,
    pick_weighted = {
      { weight = 94, entity = "data/entities/items/pickup/potion.xml" },
      { weight = 4, entity = "data/entities/items/pickup/powder_stash.xml" },
      {
        weight = 2,
        pick_weighted = {
          { weight = 98, entity="data/entities/items/pickup/potion_secret.xml" },
          { weight = 2, entity="data/entities/items/pickup/potion_random_material.xml" }
        }
      },
    }
  },
  {
    label = "spell_refresh",
    weight = 4,
    pick_weighted = {
      { weight = 98, entity = "data/entities/items/pickup/spell_refresh.xml" },
      { weight = 2, entity = "data/entities/animals/illusions/shaman_wind.xml" },
    }
  },
  {
    label = "misc_items",
    weight = 6,
    pick_weighted = lootlib.default_loot_tables.misc_items
  },
  {
    label = "random_card",
    weight = 5,
    spawn_random_cards = function()
      local rnd = Random(0,100)
			if rnd <= 50 then return 1
			elseif rnd <= 70 then return 2
			elseif rnd <= 80 then return 3
			elseif rnd <= 90 then return 4
			else return 5 end
    end,
  },
  {
    label = "wand",
    weight = 19,
    pick_weighted = {
      { weight = 25, entity = "data/entities/items/wand_level_01.xml" },
      { weight = 25, entity = "data/entities/items/wand_unshuffle_01.xml" },
      { weight = 25, entity = "data/entities/items/wand_level_02.xml" },
      { weight = 15, entity = "data/entities/items/wand_unshuffle_02.xml" },
      { weight = 6, entity = "data/entities/items/wand_level_03.xml" },
      { weight = 2, entity = "data/entities/items/wand_unshuffle_03.xml" },
      { weight = 1, entity = "data/entities/items/wand_level_04.xml" },
      { weight = 1, entity = "data/entities/items/wand_unshuffle_04.xml" },
    }
  },
  {
    label = "hearts",
    weight = 11,
    pick_weighted = {
      { weight = 88, entity = "data/entities/items/pickup/heart.xml" },
      { weight = 1, entity = "data/entities/animals/illusions/dark_alchemist.xml" },
      { weight = 10, entity = "data/entities/items/pickup/heart_better.xml" },
      { weight = 1, entity = "data/entities/items/pickup/heart_fullhp.xml" },
    }
  },
  {
    label = "chest_to_gold",
    weight = 3,
    func = function(ctx)
      if ctx.entity_id ~= nil then
        EntityConvertToMaterial(ctx.entity_id, "gold")
      end
    end
  },
  { label = "add_2_rolls", weight = 1, var = "rolls", add = 2 },
  { label = "add_3_rolls", weight = 1, var = "rolls", add = 3 },
}

lootlib.default_loot_tables.chest_random_super_base = {
  {
    label = "potion",
    weight = 10,
    pick_chance = {
      {
        chance = 30,
        do_all = {
          { entity = "data/entities/items/pickup/potion.xml" },
          { entity = "data/entities/items/pickup/potion.xml" },
          { entity = "data/entities/items/pickup/potion_secret.xml" },
        }
      },
      {
        chance = 100,
        do_all = {
          { entity = "data/entities/items/pickup/potion_secret.xml" },
          { entity = "data/entities/items/pickup/potion_secret.xml" },
          { entity = "data/entities/items/pickup/potion_random_material.xml" },
        }
      }
    }
  },
  {
    label = "rain_gold",
    weight = 5,
    -- TODO: i should probably add max_rolls or smth
    check = {
      func = function(ctx) return (ctx.vars.rains or 0) < 5 end,
    },
    success = {
      entity = "data/entities/projectiles/rain_gold.xml",
      var = "rains",
      add = 1,
    }
  },
  {
    label = "essence_stone",
    weight = 3,
    pick_weighted = {
      { weight = 30, entity = "data/entities/items/pickup/waterstone.xml" },
      { weight = 1, entity = "data/entities/items/pickup/poopstone.xml" },
    }
  },
  {
    label = "wand",
    weight = 21,
    pick_weighted = {
      { weight = 25, entity = "data/entities/items/wand_level_04.xml" },
      { weight = 25, entity = "data/entities/items/wand_unshuffle_04.xml" },
      { weight = 25, entity = "data/entities/items/wand_level_05.xml" },
      { weight = 15, entity = "data/entities/items/wand_unshuffle_05.xml" },
      { weight = 6, entity = "data/entities/items/wand_level_06.xml" },
      { weight = 2, entity = "data/entities/items/wand_unshuffle_06.xml" },
      { weight = 1, entity = "data/entities/items/wand_level_06.xml" },
      { weight = 1, entity = "data/entities/items/wand_level_10.xml" },
    }
  },
  {
    label = "hearts",
    weight = 21,
    pick_weighted = {
      { weight = 89, entity = "data/entities/items/pickup/heart.xml" },
      { weight = 10, entity = "data/entities/items/pickup/heart_better.xml" },
      { weight = 1, entity = "data/entities/items/pickup/heart_fullhp.xml" },
    }
  },
  { label = "add_2_rolls", weight = 38, var = "rolls", add = 2 },
  { label = "add_3_rolls", weight = 2, var = "rolls", add = 3 },
}

lootlib.default_loot_tables.chest_random_super = {
  {
    weight = 100000,
    pick_weighted = lootlib.default_loot_tables.chest_random_super_base,
  },
  {
    label = "sampo",
    -- TODO: adding max_rolls and other parameters for the root loot table would be nice
    weight = 1,
    func = function(ctx)
      EntityLoadEndGameItem("data/entities/animals/boss_centipede/sampo.xml", ctx.vars.pos_x, ctx.vars.pos_y)
    end
  },
}

lootlib.default_loot_tables.utility_box = {
  { label = "bomb", weight = 2, entity = "data/entities/projectiles/bomb_small.xml", is_bad = true },
  {
    label = "spell_refresh",
    weight = 3,
    pick_weighted = {
      { weight = 98, entity = "data/entities/items/pickup/spell_refresh.xml" },
      { weight = 2, entity = "data/entities/animals/illusions/shaman_wind.xml" }
    }
  },
  {
    label = "misc_items",
    weight = 6,
    pick_weighted = lootlib.default_loot_tables.misc_items
  },
  {
    label = "random_card",
    weight = 86,
    card_filter = function (card)
      return card.type == ACTION_TYPE_UTILITY or card.type == ACTION_TYPE_MODIFIER
    end,
    spawn_random_cards = function()
      local rnd = Random(0,100)
			if rnd <= 40 then return 2
			elseif rnd <= 60 then return 3
			elseif rnd <= 77 then return 4
			elseif rnd <= 90 then return 5
			else return 6 end
    end
  },
  { label = "add_2_rolls", weight = 2, var = "rolls", add = 2 },
  { label = "add_3_rolls", weight = 3, var = "rolls", add = 3 },
}

--------------------------------

return lootlib
