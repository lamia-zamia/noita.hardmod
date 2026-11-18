local eid = GetUpdatedEntityID()
local comp = GetUpdatedComponentID()
local x, y = EntityGetTransform(eid)

local player = EntityGetInRadiusWithTag(x, y, 20, "player_unit")
if player and #player > 0 then
  ModSettingSet("noita.hardmod.cheese_room_visited", true)

  GameTriggerMusicFadeOutAndDequeueAll(10.0)
	GameTriggerMusicEvent("music/oneshot/huussi", false, x, y)

  EntityRemoveComponent(eid, comp)
end
