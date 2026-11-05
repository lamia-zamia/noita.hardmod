local entity_id = GetUpdatedEntityID()
if EntityGetFirstComponentIncludingDisabled(entity_id, "AbilityComponent") then return end

local item_action_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemActionComponent")
if not item_action_comp then return end

local id = ComponentGetValue2(item_action_comp, "action_id")
local spells = dofile_once("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/spells_materialised/keyed_spell_table.lua")
local spell = spells[id]

local add_cast = function()
	local ability_comp = EntityAddComponent2(entity_id, "AbilityComponent", {
		_tags="enabled_in_hand",
		ui_name=spell.name,
		entity_file="mods/noita.hardmod/files/modules/vanilla_perk_rebalances/spells_materialised/empty.xml",
		rotate_hand_amount=0.05,
		throw_as_item=true,
		simulate_throw_as_item=true,
		use_entity_file_as_projectile_info_proxy=true,
	})
	ComponentObjectSetValue2(ability_comp, "gun_config", "deck_capacity", 0)
end

local add_inert = function()
	local ability_comp = EntityAddComponent2(entity_id, "AbilityComponent", {
		_tags="enabled_in_hand",
		ui_name=spell.name,
		entity_file="",
		rotate_hand_amount=0.05,
	})
	ComponentObjectSetValue2(ability_comp, "gun_config", "deck_capacity", 0)
end

local type_handler = {
	add_cast,	--ACTION_TYPE_PROJECTILE
	add_cast,	--ACTION_TYPE_STATIC_PROJECTILE
	add_inert,	--ACTION_TYPE_MODIFIER
	add_inert,	--ACTION_TYPE_DRAW_MANY
	add_cast,	--ACTION_TYPE_MATERIAL
	add_cast,	--ACTION_TYPE_OTHER
	add_cast,	--ACTION_TYPE_UTILITY
	add_inert,	--ACTION_TYPE_PASSIVE
}

if spell and type_handler[spell.type+1] then
	type_handler[spell.type+1]()
end

local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
if not item_comp then return end
ComponentSetValue2(item_comp, "is_equipable_forced", true) -- allow manual selecting it while in item inventory
