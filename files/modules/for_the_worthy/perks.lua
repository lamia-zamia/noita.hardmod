local root = "mods/noita.hardmod/files/modules/for_the_worthy/"
local hooks = {}

dofile_once(root.."shared.lua")

hooks.new_perks = {
	{
		id = "HARDMOD_HELL_PROTECTION_EXPLOSION",
		ui_name = "$hardmod_perk_protection_explosion_name",
		ui_description = "$hardmod_perk_protection_explosion_desc",
		ui_icon = root.."gfx/perks/protection_explosion_016.png",
		perk_icon = root.."gfx/perks/protection_explosion.png",
		stackable = false, not_in_default_perk_pool = true, not_progress = true,
		func = function(perk, player)
			local dmg_comp = EntityGetFirstComponent(player, "DamageModelComponent")
			if dmg_comp then
				local current_mtp = ComponentObjectGetValue2(dmg_comp, "damage_multipliers", "explosion")
				ComponentObjectSetValue2(dmg_comp, "damage_multipliers", "explosion", current_mtp * 0.5)
			end
		end,
		func_remove = function(player)
			local dmg_comp = EntityGetFirstComponent(player, "DamageModelComponent")
			if dmg_comp then
				local current_mtp = ComponentObjectGetValue2(dmg_comp, "damage_multipliers", "explosion")
				ComponentObjectSetValue2(dmg_comp, "damage_multipliers", "explosion", current_mtp * 4)
			end
		end,
	},
	{
		id = "HARDMOD_HELL_EXPLODING_CORPSES",
		ui_name = "$perk_exploding_corpses",
		ui_description = "$hardmod_perk_exploding_corpses_desc",
		ui_icon = "data/ui_gfx/perk_icons/exploding_corpses.png",
		perk_icon = "data/items_gfx/perks/exploding_corpses.png",
		game_effect = "EXPLODING_CORPSE_SHOTS",
		stackable = false, not_in_default_perk_pool = true, not_progress = true,
		func = function(perk, player)
			add_halo_level(player, -1)

			local dmg_comp = EntityGetFirstComponent(player, "DamageModelComponent")
			if dmg_comp then
				local current_mtp = ComponentObjectGetValue2(dmg_comp, "damage_multipliers", "explosion")
				ComponentObjectSetValue2(dmg_comp, "damage_multipliers", "explosion", current_mtp * 0.5)
			end
		end,
		func_remove = function(player)
			local dmg_comp = EntityGetFirstComponent(player, "DamageModelComponent")
			if dmg_comp then
				local current_mtp = ComponentObjectGetValue2(dmg_comp, "damage_multipliers", "explosion")
				ComponentObjectSetValue2(dmg_comp, "damage_multipliers", "explosion", current_mtp * 4)
			end
		end,
	},
	{
		id = "HARDMOD_HELL_PROTECTION_ELECTRICITY",
		ui_name = "$hardmod_perk_protection_electricity_name",
		ui_description = "$hardmod_perk_protection_electricity_desc",
		ui_icon = root.."gfx/perks/protection_electricity_016.png",
		perk_icon = root.."gfx/perks/protection_electricity.png",
		stackable = false, not_in_default_perk_pool = true, not_progress = true,
		func = function(perk, player)
			local dmg_comp = EntityGetFirstComponent(player, "DamageModelComponent")
			if dmg_comp then
				local current_mtp = ComponentObjectGetValue2(dmg_comp, "damage_multipliers", "electricity")
				ComponentObjectSetValue2(dmg_comp, "damage_multipliers", "electricity", current_mtp * 0.5)
			end
		end,
		func_remove = function(player)
			local dmg_comp = EntityGetFirstComponent(player, "DamageModelComponent")
			if dmg_comp then
				local current_mtp = ComponentObjectGetValue2(dmg_comp, "damage_multipliers", "electricity")
				ComponentObjectSetValue2(dmg_comp, "damage_multipliers", "electricity", current_mtp * 4)
			end
		end,
	},
	{
		id = "HARDMOD_HELL_PROTECTION_MELEE",
		ui_name = "$hardmod_perk_protection_melee_name",
		ui_description = "$hardmod_perk_protection_melee_desc",
		ui_icon = root.."gfx/perks/protection_melee_016.png",
		perk_icon = root.."gfx/perks/protection_melee.png",
		stackable = false, not_in_default_perk_pool = true, not_progress = true,
		func = function(perk, player)
			local dmg_comp = EntityGetFirstComponent(player, "DamageModelComponent")
			if dmg_comp then
				local current_mtp = ComponentObjectGetValue2(dmg_comp, "damage_multipliers", "melee")
				ComponentObjectSetValue2(dmg_comp, "damage_multipliers", "melee", current_mtp * 0.5)
			end
		end,
		func_remove = function(player)
			local dmg_comp = EntityGetFirstComponent(player, "DamageModelComponent")
			if dmg_comp then
				local current_mtp = ComponentObjectGetValue2(dmg_comp, "damage_multipliers", "melee")
				ComponentObjectSetValue2(dmg_comp, "damage_multipliers", "melee", current_mtp * 4)
			end
		end,
	},
	{
		id = "HARDMOD_HELL_CONTACT_DAMAGE",
		ui_name = "$perk_contact_damage",
		ui_description = "$perkdesc_contact_damage",
		ui_icon = "data/ui_gfx/perk_icons/contact_damage.png",
		perk_icon = "data/items_gfx/perks/contact_damage.png",
		stackable = false, not_in_default_perk_pool = true, not_progress = true,
		func = function(perk, player)
			local x,y = EntityGetTransform(player)
			local child_id = EntityLoad("data/entities/misc/perks/contact_damage.xml", x, y)
			EntityAddTag(child_id, "perk_entity")
			EntityAddChild(player, child_id)
		end,
		func_enemy = function(perk, player)
			local x,y = EntityGetTransform(player)
			local child_id = EntityLoad("data/entities/misc/perks/contact_damage_enemy.xml", x, y)
			EntityAddChild(player, child_id)
		end,
	}
}

return hooks
