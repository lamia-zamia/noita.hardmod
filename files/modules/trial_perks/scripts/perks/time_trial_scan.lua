
local effect_comp = EntityGetFirstComponentIncludingDisabled(GetUpdatedEntityID(), "GameEffectComponent")
if effect_comp then
	local frames_left = ComponentGetValue2(effect_comp, "frames")
	if frames_left and frames_left <= 630 then -- +30 for script trigger margin
		local x, y = EntityGetTransform(GetUpdatedEntityID())
		GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/heartbeat/create", x, y)
	end
end
