local eid = GetUpdatedEntityID()
local x, y = EntityGetTransform(eid)

if not GameHasFlagRun("tower_visited_all") then return end
if #EntityGetInRadiusWithTag(x, y, 60, "player_unit") < 1 then return end

EntityKill(eid)
print("spawning reward")

EntityLoad("data/entities/items/wands/wand_good/wand_good_1.xml", x + 20, y + 12)
EntityLoad("data/entities/items/wands/wand_good/wand_good_2.xml", x, y + 12)
EntityLoad("data/entities/items/wands/wand_good/wand_good_3.xml", x - 20, y + 12)

EntityLoad("data/entities/particles/image_emitters/chest_effect.xml", x, y)
GamePlaySound("data/audio/Desktop/projectiles.snd", "player_projectiles/crumbling_earth/create", x, y)
