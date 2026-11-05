dofile_once("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/spells_materialised/spell_behaviour.lua")

function shot(projectile)
	if EntityGetName(projectile) ~= "hardmod.empty" then return end --so sick of this nonsense script_shot bs.
	--might genuinely replace with just checking mousebuttonjustdown atp

	local entity_id = GetUpdatedEntityID()
	local parent = EntityGetParent(entity_id)
	local inv2 = EntityGetFirstComponentIncludingDisabled(parent, "Inventory2Component")
	if not inv2 then return end

	local held_item = ComponentGetValue2(inv2, "mActualActiveItem")

	local item_action_comp = EntityGetFirstComponentIncludingDisabled(held_item, "ItemActionComponent")
	if not item_action_comp then return end

	local item_comp = EntityGetFirstComponentIncludingDisabled(held_item, "ItemComponent")
	if not item_comp then return end
	local uses_remaining = ComponentGetValue2(item_comp, "uses_remaining")
	if uses_remaining == 0 then return end

	local id = ComponentGetValue2(item_action_comp, "action_id")
	cast(entity_id, id, inv2, held_item, uses_remaining)

	if uses_remaining ~= -1 then
		ComponentSetValue2(item_comp, "uses_remaining", uses_remaining - 1)
		if uses_remaining == 1 then
			local x,y = EntityGetTransform(parent)
			GamePlaySound("data/audio/Desktop/items.bank", "magic_wand/action_consumed", x, y)
		end
	end
end