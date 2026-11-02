dofile_once( "mods/noita.hardmod/files/modules/trial_perks/scripts/trial_perk_utils.lua" )
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

return {
	new_perks = {
		{
			id = "HARDMOD_TIME_TRIAL",
			ui_name = "$hardmod_perk_time_trial_name",
			ui_description = "$hardmod_perk_time_trial_desc",
			ui_icon = "mods/noita.hardmod/files/modules/trial_perks/gfx/ui_gfx/perks/time_trial_016.png",
			perk_icon = "mods/noita.hardmod/files/modules/trial_perks/gfx/ui_gfx/perks/time_trial.png",
			stackable = true,
			one_off_effect = true,
			usable_by_enemies = false,
			func = function( entity_perk_item, entity_who_picked, item_name, pickup_count )
				if reflecting then return end
				dofile_once( "data/scripts/lib/utilities.lua" )

				-- register the current y position to disqualify nearby hearts
				local x, y = EntityGetTransform( entity_who_picked )
				utils.SetInternalInt( entity_who_picked, "hardmod_time_trial_start_y", y )

				-- add GameEffect, if it doesn't exist already
				local game_effect = EntityGetAllChildren( entity_who_picked, "hardmod_time_trial_game_effect" )[1]
				if not game_effect then
					LoadGameEffectEntityTo( entity_who_picked, "mods/noita.hardmod/files/modules/trial_perks/entities/game_effects/effect_time_trial.xml" )
				end
			end,
			_remove = function( entity_who_picked )
				utils.EntityRemoveAllByTag( entity_who_picked, "hardmod_time_trial" )
			end,
		},
		{
			id = "HARDMOD_GLASS_HEART",
			ui_name = "$hardmod_perk_glass_heart_name",
			ui_description = "$hardmod_perk_glass_heart_desc",
			ui_icon = "mods/noita.hardmod/files/modules/trial_perks/gfx/ui_gfx/perks/glass_heart_016.png",
			perk_icon = "mods/noita.hardmod/files/modules/trial_perks/gfx/ui_gfx/perks/glass_heart.png",
			stackable = true,
			one_off_effect = true,
			usable_by_enemies = false,
			func = function( entity_perk_item, entity_who_picked, item_name, pickup_count )
				if reflecting then return end
				dofile_once( "data/scripts/lib/utilities.lua" )

				-- register the current y position to disqualify nearby hearts
				local x, y = EntityGetTransform( entity_who_picked )
				utils.SetInternalInt( entity_who_picked, "hardmod_glass_heart_start_y", y )

				-- add a damage_received script
				EntityAddComponent( entity_who_picked, "LuaComponent",
				{
					_tags = "perk_component,hardmod_glass_heart",
					script_damage_received = "mods/noita.hardmod/files/modules/trial_perks/scripts/perks/glass_heart_on_damage.lua",
					execute_every_n_frame = "-1",
				})

				-- add GameEffect, if it doesn't exist already
				local game_effect = EntityGetAllChildren( entity_who_picked, "hardmod_glass_heart_game_effect" )[1]
				if not game_effect then
					LoadGameEffectEntityTo( entity_who_picked, "mods/noita.hardmod/files/modules/trial_perks/entities/game_effects/effect_glass_heart.xml" )
				end
			end,
			_remove = function( entity_who_picked )
				utils.EntityRemoveAllByTag( entity_who_picked, "hardmod_glass_heart" )
			end,
		},
	}
}