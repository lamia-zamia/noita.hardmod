possession_limit_per_biome = {
    {id="$biome_coalmine",limit=1},
    {id="$hardmod_biomename_infested_mines",limit=1},
    {id="$biome_coalmine_alt",limit=1},
    {id="$biome_forest",limit=2},
    {id="$biome_holymountain",limit=0},
    {id="$biome_excavationsite",limit=1},
    {id="$hardmod_biomename_sand_pits",limit=1},
    {id="$biome_fungicave",limit=1},
    {id="$biome_snowcave",limit=1},
    {id="$biome_snowcastle",limit=1},
    {id="$biome_rainforest",limit=2},
    {id="$biome_rainforest_dark",limit=3},
    {id="$biome_vault",limit=2},
    {id="$biome_crypt",limit=3},
    {id="$biome_desert",limit=6},
    {id="$biome_fungiforest",limit=6},
    {id="$biome_meat",limit=3},
    {id="$biome_robobase",limit=3},
    {id="$biome_winter_caves",limit=20},
    {id="$biome_boss_victoryroom",limit=-1}
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