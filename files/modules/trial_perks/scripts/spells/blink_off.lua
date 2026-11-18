
local owner = nil
local proj_comp = EntityGetFirstComponentIncludingDisabled(GetUpdatedEntityID(), "ProjectileComponent")
if proj_comp then
	local mWhoShot = ComponentGetValue2(proj_comp, "mWhoShot")
	if mWhoShot then
		owner = mWhoShot
	end
end

local x, y = EntityGetTransform(owner)
EntityLoad("mods/noita.hardmod/files/modules/trial_perks/gfx/spells/blink_tele_particles.xml", x, y)
GamePlaySound("data/audio/Desktop/player.bank", "player_projectiles/megalaser/launch", x, y)
