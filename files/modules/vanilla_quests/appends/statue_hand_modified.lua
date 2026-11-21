local orig_mark_as_complete = mark_as_complete
function mark_as_complete()
  local eid = GetUpdatedEntityID()
	local x, y = EntityGetTransform(eid)

  orig_mark_as_complete()

  if EntityHasTag(eid, "statue_hand_2") then
    CreateItemActionEntity("SUMMON_PORTAL", x - 5, y - 5)
    EntityLoad("data/entities/items/pickup/summon_portal_broken.xml", x + 5, y - 5)
  end
end
