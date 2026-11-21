local entity_id = GetUpdatedEntityID()
local root = EntityGetRootEntity(entity_id)
local x,y = EntityGetTransform(entity_id)

local nearby_players = EntityGetInRadiusWithTag(x, y, 64, "player_unit")
if nearby_players then
	for i,player in ipairs(nearby_players) do
		GetGameEffectLoadTo(player, "FOOD_POISONING", false)
	end
end
