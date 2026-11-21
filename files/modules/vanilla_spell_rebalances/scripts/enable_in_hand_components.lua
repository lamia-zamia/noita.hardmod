for _,child in ipairs(EntityGetAllChildren(GetUpdatedEntityID()) or {}) do
	EntitySetComponentsWithTagEnabled(child, "enabled_in_hand", true)
end