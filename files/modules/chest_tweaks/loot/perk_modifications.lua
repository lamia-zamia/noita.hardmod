local lootlib = dofile_once("mods/noita.hardmod/lib/lootlib.lua")---@type lootlib
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

lootlib.on_chest_pre_open(function (ctx, tbl, tname)
	local extra_rolls = (utils.GetPerkPickupCount("HARDMOD_BETTER_CHESTS") or 0) * 3

	if tname == "chest_random_super" then
		extra_rolls = extra_rolls + 5
	elseif tname == "chest_random" then
		extra_rolls = extra_rolls + (Random() > 0.5 and 1 or 0)
	end

	ctx.vars.rolls = ctx.vars.rolls + extra_rolls
end)

lootlib.on_chest_post_open(function (ctx, tbl, tname)
  if tname ~= "chest_random" then return end

  local treasure_hunter_stacks = utils.GetPerkPickupCount("HARDMOD_TREASURE_HUNTER")
  local nearest_player = EntityGetInRadiusWithTag(ctx.vars.pos_x, ctx.vars.pos_y, 100, "player_unit")[1]
	if nearest_player == nil then return end

  local saved_gold = utils.GetInternalInt(nearest_player, "hardmod_treasure_hunter_gold_saved") or 0
	local gold = (saved_gold + 100) * treasure_hunter_stacks

  ctx.vars.gold = ctx.vars.gold + gold

  utils.SetInternalInt(nearest_player, "hardmod_treasure_hunter_gold_saved", 0)
end)
