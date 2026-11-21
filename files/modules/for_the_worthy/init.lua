local hooks = {}---@type hooks
local root = "mods/noita.hardmod/files/modules/for_the_worthy/"

dofile_once(root.."shared.lua")

ModLuaFileAppend("data/scripts/perks/perk.lua", root.."appends/perk.lua")
ModLuaFileAppend("data/scripts/animals/necromancer_shop_init.lua", root.."appends/necromancer_shop_init.lua")
ModLuaFileAppend("data/scripts/biomes/temple_altar.lua", root.."appends/temple_altar.lua")

ModLuaFileAppend("data/scripts/items/__drop_money.lua", root.."appends/drop_money.lua")

function hooks.new_eid(eid)
	if not GameHasFlagRun("hardmod_hell") then return end
	if not EntityHasTag(eid, "enemy") then return end

	HardmodTransformEnemyHell(eid)
end

return hooks
