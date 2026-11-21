local orig_spawn_wands = spawn_wands
function spawn_wands(x, y)
	if not g_items then return end

	local item = random_from_table(g_items, x-5, y)
	if not item then return end

	if item.entities or not item.entity or item.min_count ~= 1 or item.max_count ~= 1 then
		return orig_spawn_wands(x, y)
	end

	local wand = EntityLoad(item.entity, x, y + 5)
	if wand and wand ~= 0 and EntityHasTag(wand, "wand") then
		EntityAddTag(wand, "pedestal_wand")
	end

	return wand
end
