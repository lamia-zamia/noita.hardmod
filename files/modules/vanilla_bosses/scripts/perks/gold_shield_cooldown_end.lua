local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")

local owner = EntityGetRootEntity( GetUpdatedEntityID() )
if owner == nil then return end
local shield = EntityGetAllChildren( owner, "hardmod_gold_shield" )[1]
if shield == nil then return end

-- re-activate base particles
EntitySetComponentsWithTagEnabled( shield, "hardmod_gold_shield_inactive", true )
local x, y = EntityGetTransform( shield )
