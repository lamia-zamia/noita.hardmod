local entity_id = GetUpdatedEntityID()
local x,y = EntityGetTransform(entity_id)

for _,crystal in ipairs(EntityGetInRadiusWithTag(x, y, 50, "hm_crystal")) do
	if EntityGetName(crystal) == "hardmod.collapse_crystal" then
		EntityInflictDamage(crystal, 20, "NONE", "kill the fuckin crystal", "NONE", 0, 0)
		dofile_once("data/scripts/perks/perk.lua")
		perk_spawn_many(x-24, y-2)
		for _,luacomp in ipairs(EntityGetComponent(crystal, "LuaComponent") or {}) do
			EntitySetComponentIsEnabled(crystal, luacomp, false)
		end
		EntityKill(entity_id)
	end
end