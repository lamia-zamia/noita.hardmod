local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")

local shield_id = GetUpdatedEntityID()
local owner = EntityGetRootEntity(shield_id)
local x, y = EntityGetTransform(owner)

local radius = utils.GetInternalInt(shield_id, "hardmod_gold_shield_radius") or 24
local duration = utils.GetInternalInt(shield_id, "hardmod_gold_shield_duration") or 60

local projs_to_kill = {}
local projectiles = EntityGetInRadiusWithTag(x, y, radius, "projectile")
if #projectiles > 0 then
	for i,proj_id in ipairs(projectiles) do
		local px, py = EntityGetTransform(proj_id)
		local proj_comp = EntityGetFirstComponentIncludingDisabled(proj_id, "ProjectileComponent")
		if proj_comp ~= nil then			
			local mWhoShot = ComponentGetValue2(proj_comp, "mWhoShot")
			if mWhoShot ~= owner then
				EntityLoad("mods/noita.hardmod/files/modules/vanilla_bosses/gfx/particles/gold_shield_particle.xml", px, py)
				EntityKill(proj_id)
			end
		end
	end
end

local trigger_frame = utils.GetInternalInt(shield_id, "hardmod_gold_shield_trigger_frame") or -1
if trigger_frame == -1 then
	utils.SetInternalInt(shield_id, "hardmod_gold_shield_trigger_frame", GameGetFrameNum())
elseif GameGetFrameNum() - trigger_frame > duration then
	GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/shield/deactivate", x, y )
	EntitySetComponentsWithTagEnabled( shield_id, "hardmod_gold_shield_active", false )

	-- show standby particles right away on Squidward
	if EntityHasTag( owner, "miniboss" ) then
		EntitySetComponentsWithTagEnabled( shield_id, "hardmod_gold_shield_inactive", true )
	end
end