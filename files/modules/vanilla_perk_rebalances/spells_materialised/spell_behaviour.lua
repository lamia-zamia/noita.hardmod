local keyed_spell_table = dofile_once("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/spells_materialised/keyed_spell_table.lua")

local types = {
	[0] = true,		--ACTION_TYPE_PROJECTILE
	[1] = true,		--ACTION_TYPE_STATIC_PROJECTILE
	[2] = false,	--ACTION_TYPE_MODIFIER
	[3] = false,	--ACTION_TYPE_DRAW_MANY
	[4] = true,		--ACTION_TYPE_MATERIAL
	[5] = true,		--ACTION_TYPE_OTHER
	[6] = true,		--ACTION_TYPE_UTILITY
	[7] = false,	--ACTION_TYPE_PASSIVE
}

---cast the shit
---@param caster entity_id
---@param spell string
---@param inventory2_component component_id
---@param held_spell entity_id
---@param remaining_uses int
---@param is_recursed bool?
function cast(caster, spell, inventory2_component, held_spell, remaining_uses, is_recursed)
	if not keyed_spell_table[spell] then return end
	if not types[keyed_spell_table[spell].type] then return end

	local custom_spell = SPELLS_MATERIALISED_CUSTOM_BEHAVIOUR[spell]
	if custom_spell then
		if not (is_recursed and custom_spell.do_not_recurse) then
			custom_spell.func(caster, inventory2_component, held_spell, remaining_uses)
		end
		return
	end
	local fake_cast = EntityLoad("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/spells_materialised/fake_cast.xml")
	EntitySetTransform(fake_cast, EntityGetTransform(caster))
	EntityAddChild(caster, fake_cast)

	local inventory_comp = EntityGetAllChildren(fake_cast)[1]
	local gun = EntityGetAllChildren(inventory_comp)[1]

	local plat_shooter = EntityGetFirstComponentIncludingDisabled(fake_cast, "PlatformShooterPlayerComponent")
	if not plat_shooter then return end

	local fake_cast_spell_card = EntityCreateNew()
	EntityAddChild(gun, fake_cast_spell_card)
	EntityAddComponent2(fake_cast_spell_card, "ItemActionComponent", {action_id = spell})

	local fake_cast_item_comp = EntityAddComponent2(fake_cast_spell_card, "ItemComponent")
	ComponentSetValue2(fake_cast_item_comp, "inventory_slot", 1, 1)

	ComponentSetValue2(plat_shooter, "mForceFireOnNextUpdate", true)
end

SPELLS_MATERIALISED_CUSTOM_BEHAVIOUR = {
	CESSATION = {
		func = function(caster, inventory2_component, held_spell, remaining_uses)
			local platformshooter = EntityGetFirstComponentIncludingDisabled(EntityGetParent(caster), "PlatformShooterPlayerComponent")
			if platformshooter ~= nil then
				ComponentSetValue2( platformshooter, "mCessationDo", true )
				ComponentSetValue2( platformshooter, "mCessationLifetime", 20)
			end
		end
	},
	ALPHA = {
		do_not_recurse = true,
		func = function(caster, inventory2_component, held_spell, remaining_uses)
			local children = EntityGetAllChildren(EntityGetParent(caster))
			local spell_inventory
			for _,child in ipairs(children or {}) do
				if EntityGetName(child) == "inventory_full" then
					spell_inventory = child break
				end
			end
			if not spell_inventory then return end

			local spells = EntityGetAllChildren(spell_inventory) or {}
			local spell = spells[1]
			if not spell then return end

			local item_action_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemActionComponent")
			if not item_action_comp then return end

			cast(caster, ComponentGetValue2(item_action_comp, "action_id"), inventory2_component, held_spell, remaining_uses, true)
		end,
	},
	GAMMA = {
		do_not_recurse = true,
		func = function(caster, inventory2_component, held_spell, remaining_uses)
			local children = EntityGetAllChildren(EntityGetParent(caster))
			local spell_inventory
			for _,child in ipairs(children or {}) do
				if EntityGetName(child) == "inventory_full" then
					spell_inventory = child break
				end
			end
			if not spell_inventory then return end

			local spells = EntityGetAllChildren(spell_inventory) or {}
			local spell = spells[#spells]
			if not spell then return end

			local item_action_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemActionComponent")
			if not item_action_comp then return end

			cast(caster, ComponentGetValue2(item_action_comp, "action_id"), inventory2_component, held_spell, remaining_uses, true)
		end,
	},
	TAU = {
		do_not_recurse = true,
		func = function(caster, inventory2_component, held_spell, remaining_uses)
			local children = EntityGetAllChildren(EntityGetParent(caster))
			local item_inventory
			local spell_inventory
			for _,child in ipairs(children or {}) do
				local child_name = EntityGetName(child)
				if child_name == "inventory_quick" then
					item_inventory = child
				elseif child_name == "inventory_full" then
					spell_inventory = child
				end
				if item_inventory and spell_inventory then break end
			end

			local inventory = {}
			for _,item in ipairs(EntityGetAllChildren(item_inventory) or {}) do
				local item_action_comp = EntityGetFirstComponentIncludingDisabled(item, "ItemActionComponent")
				if item_action_comp then
					local spell_id = ComponentGetValue2(item_action_comp, "action_id")
					inventory[#inventory+1] = {eid = item, aid = spell_id}
				end
			end
			for _,spell in ipairs(EntityGetAllChildren(spell_inventory) or {}) do
				local item_action_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemActionComponent")
				if item_action_comp then
					local spell_id = ComponentGetValue2(item_action_comp, "action_id")
					inventory[#inventory+1] = {eid = spell, aid = spell_id}
				end
			end

			local held_spell_position
			for index, spell in ipairs(inventory) do
				if spell.eid == held_spell then
					held_spell_position = index
				end
			end
			if inventory[held_spell_position+1] then
				cast(caster, inventory[held_spell_position+1].aid, inventory2_component, held_spell, remaining_uses, true)
				if inventory[held_spell_position+2] then
					cast(caster, inventory[held_spell_position+2].aid, inventory2_component, held_spell, remaining_uses, true)
				end
			end
		end,
	},
	OMEGA = {
		do_not_recurse = true,
		func = function(caster, inventory2_component, held_spell, remaining_uses)
			local children = EntityGetAllChildren(EntityGetParent(caster))
			local spell_inventory
			for _,child in ipairs(children or {}) do
				local child_name = EntityGetName(child)
				if child_name == "inventory_full" then
					spell_inventory = child break
				end
			end

			local inventory = {}
			for _,spell in ipairs(EntityGetAllChildren(spell_inventory) or {}) do
				local item_action_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemActionComponent")
				if item_action_comp  then
					local spell_id = ComponentGetValue2(item_action_comp, "action_id")
					inventory[#inventory+1] = {eid = spell, aid = spell_id}
				end
			end

			for _, spell in ipairs(inventory) do
				if not (SPELLS_MATERIALISED_CUSTOM_BEHAVIOUR[spell.aid] or {}).do_not_recurse then
					cast(caster, spell.aid, inventory2_component, held_spell, remaining_uses, true)
				end
			end
		end,
	},
	PHI = {
		do_not_recurse = true,
		func = function(caster, inventory2_component, held_spell, remaining_uses)
			local children = EntityGetAllChildren(EntityGetParent(caster))
			local spell_inventory
			for _,child in ipairs(children or {}) do
				local child_name = EntityGetName(child)
				if child_name == "inventory_full" then
					spell_inventory = child break
				end
			end

			local inventory = {}
			for _,spell in ipairs(EntityGetAllChildren(spell_inventory) or {}) do
				local item_action_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemActionComponent")
				if item_action_comp then
					local spell_id = ComponentGetValue2(item_action_comp, "action_id")
					if not (keyed_spell_table[spell_id].type == 0) then goto continue end
					inventory[#inventory+1] = {eid = spell, aid = spell_id}
				end
				::continue::
			end

			for _, spell in ipairs(inventory) do
				if not (SPELLS_MATERIALISED_CUSTOM_BEHAVIOUR[spell.aid] or {}).do_not_recurse then
					cast(caster, spell.aid, inventory2_component, held_spell, remaining_uses, true)
				end
			end
		end,
	},
	SIGMA = {
		do_not_recurse = true,
		func = function(caster, inventory2_component, held_spell, remaining_uses)
			local children = EntityGetAllChildren(EntityGetParent(caster))
			local spell_inventory
			for _,child in ipairs(children or {}) do
				local child_name = EntityGetName(child)
				if child_name == "inventory_full" then
					spell_inventory = child break
				end
			end

			local inventory = {}
			for _,spell in ipairs(EntityGetAllChildren(spell_inventory) or {}) do
				local item_action_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemActionComponent")
				if item_action_comp then
					local spell_id = ComponentGetValue2(item_action_comp, "action_id")
					if not (keyed_spell_table[spell_id].type == 1) then goto continue end
					inventory[#inventory+1] = {eid = spell, aid = spell_id}
				end
				::continue::
			end

			for _, spell in ipairs(inventory) do
				if not (SPELLS_MATERIALISED_CUSTOM_BEHAVIOUR[spell.aid] or {}).do_not_recurse then
					cast(caster, spell.aid, inventory2_component, held_spell, remaining_uses, true)
				end
			end
		end,
	},
	ZETA = {
		do_not_recurse = true,
		func = function(caster, inventory2_component, held_spell, remaining_uses)
			local children = EntityGetAllChildren(EntityGetParent(caster))
			local item_inventory
			for _,child in ipairs(children or {}) do
				local child_name = EntityGetName(child)
				if child_name == "inventory_quick" then
					item_inventory = child break
				end
			end

			local options = {}
			for _,item in ipairs(EntityGetAllChildren(item_inventory) or {}) do
				for _, child in ipairs(EntityGetAllChildren(item) or {}) do
					local item_action_comp = EntityGetFirstComponentIncludingDisabled(child, "ItemActionComponent")
					if item_action_comp then
						local spell_id = ComponentGetValue2(item_action_comp, "action_id")
						if types[keyed_spell_table[spell_id].type] and not (SPELLS_MATERIALISED_CUSTOM_BEHAVIOUR[spell_id] or {}).do_not_recurse then
							options[#options+1] = spell_id
						end
					end
				end
			end

			SetRandomSeed(inventory2_component-GameGetFrameNum(), caster-held_spell)
			if #options > 0 then
				cast(caster, options[Random(1, #options)], inventory2_component, held_spell, remaining_uses, true)
			end
		end
	},
	DRAW_RANDOM = {
		do_not_recurse = true,
		func = function(caster, inventory2_component, held_spell, remaining_uses)
			local children = EntityGetAllChildren(EntityGetParent(caster))
			local spell_inventory
			for _,child in ipairs(children or {}) do
				local child_name = EntityGetName(child)
				if child_name == "inventory_full" then
					spell_inventory = child break
				end
			end

			local options = {}
			for _,spell in ipairs(EntityGetAllChildren(spell_inventory) or {}) do
				local item_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemComponent")
				local item_action_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemActionComponent")
				if item_comp and item_action_comp then
					local spell_id = ComponentGetValue2(item_action_comp, "action_id")
					if types[keyed_spell_table[spell_id].type] and not (SPELLS_MATERIALISED_CUSTOM_BEHAVIOUR[spell_id] or {}).do_not_recurse then
						if ComponentGetValue2(item_comp, "uses_remaining") ~= 0 then
							options[#options+1] = spell_id
						end
					end
				end
			end

			SetRandomSeed(inventory2_component-GameGetFrameNum(), caster-held_spell)
			if #options > 0 then
				cast(caster, options[Random(1, #options)], inventory2_component, held_spell, remaining_uses, true)
			end
		end
	},
	DRAW_RANDOM_X3 = {
		do_not_recurse = true,
		func = function(caster, inventory2_component, held_spell, remaining_uses)
			local children = EntityGetAllChildren(EntityGetParent(caster))
			local spell_inventory
			for _,child in ipairs(children or {}) do
				local child_name = EntityGetName(child)
				if child_name == "inventory_full" then
					spell_inventory = child break
				end
			end

			local options = {}
			for _,spell in ipairs(EntityGetAllChildren(spell_inventory) or {}) do
				local item_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemComponent")
				local item_action_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemActionComponent")
				if item_comp and item_action_comp then
					local spell_id = ComponentGetValue2(item_action_comp, "action_id")
					if types[keyed_spell_table[spell_id].type] and not (SPELLS_MATERIALISED_CUSTOM_BEHAVIOUR[spell_id] or {}).do_not_recurse then
						if ComponentGetValue2(item_comp, "uses_remaining") ~= 0 then
							options[#options+1] = spell_id
						end
					end
				end
			end

			SetRandomSeed(inventory2_component-GameGetFrameNum(), caster-held_spell)
			if #options > 0 then
				local rnd_spell = options[Random(1, #options)]
				for _=1, 3 do
					cast(caster, rnd_spell, inventory2_component, held_spell, remaining_uses, true)
				end
			end
		end
	},
	DRAW_3_RANDOM = {
		do_not_recurse = true,
		func = function(caster, inventory2_component, held_spell, remaining_uses)
			local children = EntityGetAllChildren(EntityGetParent(caster))
			local spell_inventory
			for _,child in ipairs(children or {}) do
				local child_name = EntityGetName(child)
				if child_name == "inventory_full" then
					spell_inventory = child break
				end
			end

			local options = {}
			for _,spell in ipairs(EntityGetAllChildren(spell_inventory) or {}) do
				local item_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemComponent")
				local item_action_comp = EntityGetFirstComponentIncludingDisabled(spell, "ItemActionComponent")
				if item_comp and item_action_comp then
					local spell_id = ComponentGetValue2(item_action_comp, "action_id")
					if types[keyed_spell_table[spell_id].type] and not (SPELLS_MATERIALISED_CUSTOM_BEHAVIOUR[spell_id] or {}).do_not_recurse then
						if ComponentGetValue2(item_comp, "uses_remaining") ~= 0 then
							options[#options+1] = spell_id
						end
					end
				end
			end

			SetRandomSeed(inventory2_component-GameGetFrameNum(), caster-held_spell)
			if #options > 0 then
				for _=1, 3 do
					cast(caster, options[Random(1, #options)], inventory2_component, held_spell, remaining_uses, true)
				end
			end
		end
	},
}