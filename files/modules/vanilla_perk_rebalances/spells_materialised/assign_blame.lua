local player = EntityGetParent(EntityGetParent(GetUpdatedEntityID()))
local genome_comp = EntityGetFirstComponent(player, "GenomeDataComponent")
local herd = genome_comp and ComponentGetValue2(genome_comp, "herd_id") or 0

function shot(projectile)
	local proj_comps = EntityGetComponent(projectile, "ProjectileComponent")
	for _, proj_comp in ipairs(proj_comps or {}) do
		if ComponentGetValue2(proj_comp, "mWhoShot") ~= 0 then
			ComponentSetValue2(proj_comp, "mWhoShot",player)
			ComponentSetValue2(proj_comp, "mEntityThatShot",player)
			ComponentSetValue2(proj_comp, "mShooterHerdId",herd)
		end
	end
end