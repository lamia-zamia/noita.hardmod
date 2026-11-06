possession_limit_per_biome = {
    {ids={"$biome_coalmine","$hardmod_biomename_infested_mines"},limit=1},
    {ids={"$biome_coalmine_alt"},limit=1,weight=0.5},
    {ids={"$biome_forest"},limit=2,weight=0.0},
    {ids={"$biome_holymountain"},limit=0,weight=0.0},
    {ids={"$biome_excavationsite","$hardmod_biomename_sand_pits"},limit=1},
    {ids={"$biome_fungicave"},limit=1},
    {ids={"$biome_ant_hell"},limit=1,weight=0.5},
    {ids={"$biome_snowcave","$biome_lava_excavation"},limit=1,weight=0.75},
    {ids={"$biome_snowcastle"},limit=1,weight=0.75},
    {ids={"$biome_rainforest"},limit=2},
    {ids={"$biome_rainforest_dark"},limit=3,weight=0.5},
    {ids={"$biome_vault"},limit=2},
    {ids={"$biome_crypt"},limit=3},
    {ids={"$biome_desert"},limit=3,weight=0.0},
    {ids={"$biome_pyramid"},limit=1,weight=0.25},
    {ids={"$biome_winter"},limit=2,weight=0.0},
    {ids={"$biome_fungiforest"},limit=3,weight=1.5},
    {ids={"$biome_meat"},limit=3,weight=0.5},
    {ids={"$biome_robobase"},limit=3,weight=0.5},
    {ids={"$biome_winter_caves"},limit=20,weight=1},
    {ids={"$biome_water"},limit=0,weight=0},
    {ids={"$biome_wandcave"},limit=3,weight=0.75},
    {ids={"$biome_wizardcave"},limit=3,weight=1},
    {ids={"???"},limit=0,weight=0.5},
    {ids={"$biome_boss_victoryroom"},limit=-1,weight=3},
    {ids={"$biome_evil_temple"},limit=4,weight=2},
    {ids={"$biome_esoteric_den"},limit=0,weight=0.0},
}

default_biome_limit = 3

-- local alts = dofile_once("mods/noita.hardmod/files/modules/alternate_biomes/biome_list.lua")

-- for original,variants in pairs(alts.list) do
--   for _,variant in pairs(variants) do
--     if original.name == variant.name then
--   end
-- end
-- TODO: Have alternate versions of vanilla biomes have their limit be automatically filled in

return {
    possession_limit_per_biome   = possession_limit_per_biome,
    default_biome_limit         = default_biome_limit,
}