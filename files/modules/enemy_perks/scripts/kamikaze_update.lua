
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local owner = GetUpdatedEntityID()
local x, y = EntityGetTransform(owner)

local cooldown = 90

--if not near a player or herd is player, dont explode
local nearby_players = EntityGetInRadiusWithTag(x, y, 16, "player_unit") or {}
if #nearby_players == 0 or HerdIdToString(utils.GetHerdID(owner)) == "player" then return end

EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/kamikaze_explosion.xml", x, y)
ComponentSetValue2(GetUpdatedComponentID(), "mNextExecutionTime", GameGetFrameNum()+cooldown)