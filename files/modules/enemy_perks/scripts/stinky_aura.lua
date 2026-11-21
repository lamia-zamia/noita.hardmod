local entity_id = GetUpdatedEntityID()
local root = EntityGetRootEntity(entity_id)
local x,y = EntityGetTransform(entity_id)

local nearby_players = EntityGetInRadiusWithTag(x, y, 64, "player_unit")
if nearby_players then
	for i,player in ipairs(nearby_players) do
		if #(EntityGetAllChildren(player, "stinky_aura_effect") or {}) == 0 then
			EntityAddChild(player, EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/stinky_aura_effect.xml", x, y))
		end
	end
end
