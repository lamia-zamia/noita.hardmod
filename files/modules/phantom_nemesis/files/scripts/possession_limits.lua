possession_limit_per_biome = {
    {id="mines",limit=1},
    {id="collapsed_mines",limit=1},
    {id="surface_forest",limit=2},
    {id="holy_mountain",limit=0},
    {id="coal_pits",limit=1},
    {id="fungal_caverns",limit=1},
    {id="snowy_depths",limit=1},
    {id="hiisi_base",limit=1},
    {id="jungle",limit=1},
    {id="lukki_lair",limit=3},
    {id="vault",limit=2},
    {id="temple_of_the_art",limit=3},
    {id="surface_desert",limit=6},
    {id="wandmart",limit=6},
    {id="meat_realm",limit=3},
    {id="powerplant",limit=3},
    {id="winter_caves",limit=20},
    {id="hell",limit=-1},
    {id="sky",limit=-1},
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