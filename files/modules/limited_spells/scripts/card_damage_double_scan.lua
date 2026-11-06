
local item_comp = EntityGetFirstComponentIncludingDisabled( GetUpdatedEntityID(), "ItemComponent" )
if item_comp == nil then return end

local show_particles = false
local uses_remaining = ComponentGetValue2( item_comp, "uses_remaining" )
if uses_remaining > 0 then
	show_particles = true
end

local particle_comp = EntityGetFirstComponentIncludingDisabled( GetUpdatedEntityID(), "ParticleEmitterComponent" )
if particle_comp then
	ComponentSetValue2( particle_comp, "is_emitting", show_particles )
end
