
local owner = EntityGetRootEntity(GetUpdatedEntityID())
local x, y = EntityGetTransform(owner)

local projectiles = EntityGetInRadiusWithTag(x, y, 24, "projectile")
if #projectiles > 0 then
	for _,proj_id in ipairs(projectiles) do
		local px, py = EntityGetTransform(proj_id)
		local proj_comp = EntityGetFirstComponentIncludingDisabled(proj_id, "ProjectileComponent")
		if proj_comp ~= nil then
			local damage = ComponentGetValue2(proj_comp, "damage")
			if damage and damage > 0 then
				local players = EntityGetInRadiusWithTag(x, y, 24, "player_unit")
				for _,player in ipairs(players) do
					EntityInflictDamage(player, damage * 0.5, "DAMAGE_HOLY", "projectile", "NORMAL", 0, 0)
				end
			end

			local mWhoShot = ComponentGetValue2(proj_comp, "mWhoShot")
			if mWhoShot ~= owner then
				EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/impervious_shield_particle.xml", px, py)
				EntityKill(proj_id)
			end
		end
	end
end
