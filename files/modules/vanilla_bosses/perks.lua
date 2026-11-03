local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

return {
	new_perks = {
		{
			id = "HARDMOD_GOLD_SHIELD",
			ui_name = "$hardmod_perk_divine_shield_name",
			ui_description = "$hardmod_perk_divine_shield_desc",
			ui_icon = "mods/noita.hardmod/files/modules/vanilla_bosses/gfx/ui_gfx/perks/gold_shield_016.png",
			perk_icon = "mods/noita.hardmod/files/modules/vanilla_bosses/gfx/ui_gfx/perks/gold_shield.png",
			stackable = false,
			one_off_effect = false,
			usable_by_enemies = true,
			func = function( entity_perk_item, entity_who_picked, item_name, pickup_count )
				local x, y = EntityGetTransform( entity_who_picked )
				local shield = EntityLoad( "mods/noita.hardmod/files/modules/vanilla_bosses/entity/gold_shield.xml", x, y )
				EntityAddChild( entity_who_picked, shield )
				EntitySetComponentsWithTagEnabled( shield, "hardmod_gold_shield_active", false )
				EntitySetComponentsWithTagEnabled( shield, "hardmod_gold_shield_inactive", true )

				EntityAddComponent2( entity_who_picked, "LuaComponent", {
					_tags = "perk_component,hardmod_gold_shield",
					script_damage_received = "mods/noita.hardmod/files/modules/vanilla_bosses/scripts/perks/gold_shield_on_damage.lua",
					execute_every_n_frame = -1,
				})
			end,
			func_remove = function( entity_who_picked )
				utils.EntityRemoveAllByTag( entity_who_picked, "hardmod_gold_shield" )
			end,
		},
	},
}