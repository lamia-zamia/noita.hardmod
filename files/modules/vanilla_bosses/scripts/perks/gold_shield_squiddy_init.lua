local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")

local shield_id = GetUpdatedEntityID()
local owner = EntityGetRootEntity( shield_id )

if owner ~= nil then
	local duration = utils.GetInternalInt(shield_id, "hardmod_gold_shield_duration") or 60
	LoadGameEffectEntityTo( owner,
		"mods/noita.hardmod/files/modules/vanilla_bosses/entity/status_effects/effect_protection_all_"..duration.."f.xml"
	)
end