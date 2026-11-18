dofile_once("data/scripts/lib/utilities.lua")

local entity_id = GetUpdatedEntityID()
local x,y = EntityGetTransform(entity_id)

local targets = EntityGetInRadiusWithTag(x, y, 64, "player_unit")

last_pollen = last_pollen or 0

if (#targets > 0 and GameGetFrameNum() - last_pollen > 120) then
	SetRandomSeed(x + entity_id, y + GameGetFrameNum())
	last_pollen = GameGetFrameNum()
	for i = 0, 15 do
		local pollen = EntityLoad("mods/noita.hardmod/files/modules/alternate_biomes/enemies/fungal/longleg/pollen.xml", x, y)
		--shoot_projectile(entity_id, "mods/noita.hardmod/files/modules/alternate_biomes/enemies/fungal/longleg/pollen.xml", x, y, Random(-300, 300), Random(-300, 10))
		GameShootProjectile(entity_id, x, y, x + Random(-300, 300), y + Random(-300, 300), pollen, true)
	end
end
