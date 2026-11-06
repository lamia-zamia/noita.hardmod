local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )

local x, y = EntityGetTransform( GetUpdatedEntityID() )

local function get_all_wand_actions( wand )
	local actions = {}
	local spells, always_casts = wand:GetSpells()
	for i,always_cast in ipairs( always_casts ) do
		table.insert( actions, always_cast )
	end
	for i,spell in ipairs( spells ) do
		table.insert( actions, spell )
	end

	return actions
end

local held_wand = EZWand.GetHeldWand()
if not held_wand then return end
local spells_in_wand = get_all_wand_actions( held_wand )

local show_particles = false
for i,spell in ipairs( spells_in_wand ) do
	if spell.action_id == "HARDMOD_BIG_SHOT" then
		local nearest_player = EntityGetClosestWithTag( x, y, "player_unit" )
		local last_frame_used = utils.GetInternalInt( nearest_player, "hardmod_big_shot_last_frame_used" ) or 0
		local frames_since_last_use = GameGetFrameNum() - last_frame_used
		if frames_since_last_use >= 1800 then
			show_particles = true
		end
	end
end

local particle_comp = EntityGetFirstComponentIncludingDisabled( GetUpdatedEntityID(), "ParticleEmitterComponent" )
if particle_comp then
	ComponentSetValue2( particle_comp, "is_emitting", show_particles )
end
