local entity_id = GetUpdatedEntityID()
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local is_allied_with_player = HerdIdToString(utils.GetHerdID(entity_id)) == "player" --get owner's relationship to the player

function damage_received(damage, message, attacker, is_fatal)
	local x,y = EntityGetTransform(entity_id)
	if damage <= 0 then return end
	for _,entity in ipairs(EntityGetInRadius(x, y, 70)) do
		if entity ~= entity_id and EntityGetFirstComponent(entity, "DamageModelComponent")
				and (HerdIdToString(utils.GetHerdID(entity)) == "player") == is_allied_with_player then --heal entities that have the same relationship to the player
			EntityInflictDamage(entity, -damage, "DAMAGE_HEALING", '-'..message, "NONE", 0, 0)
			local ex,ey = EntityGetTransform(entity)
			EntityLoad("data/entities/particles/heal_effect.xml", ex, ey)
		end
	end
end