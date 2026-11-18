dofile_once("mods/noita.hardmod/files/modules/trial_perks/scripts/trial_perk_utils.lua")

local owner = nil
local proj_comp = EntityGetFirstComponentIncludingDisabled(GetUpdatedEntityID(), "ProjectileComponent")
if proj_comp then
	local mWhoShot = ComponentGetValue2(proj_comp, "mWhoShot")
	if mWhoShot then
		owner = mWhoShot
	end
end

if owner == nil then return end
if not EntityHasTag(owner, "player_unit") then return end
local ctrl_comp = EntityGetFirstComponent(owner, "ControlsComponent")
if not ctrl_comp then return end

local x, y = EntityGetTransform(owner)
EntityLoad("mods/noita.hardmod/files/modules/trial_perks/gfx/spells/blink_tele_particles.xml", x, y)

local tx, ty = ComponentGetValue2(ctrl_comp, "mMousePosition")
EntityApplyTransform(GetUpdatedEntityID(), tx, ty)
EntityLoad("mods/noita.hardmod/files/modules/trial_perks/gfx/spells/blink_tele_particles.xml", tx, ty)

EntityKill(GetUpdatedEntityID())
