local orig_collision_trigger = collision_trigger
function collision_trigger(...)
	if not GameGetOrbCollectedThisRun(7) then
		return
	end

	return orig_collision_trigger(...)
end
