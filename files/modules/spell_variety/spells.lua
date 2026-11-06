---@diagnostic disable: undefined-global
local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

return {
	new_spells = {
		{
			id                  = "HARDMOD_ECHO_SHOT",
			name 		        = "$hardmod_spell_echo_shot_name",
			description         = "$hardmod_spell_echo_shot_desc",
			sprite              = "mods/noita.hardmod/files/modules/spell_variety/gfx/ui_gfx/spells/echo_shot.png",
			related_projectiles	= { "mods/noita.hardmod/files/modules/spell_variety/entities/spells/echo_shot.xml" },
			type 		        = ACTION_TYPE_PROJECTILE,
			spawn_level         = "0,1,2,3,4",
			spawn_probability   = "0.4,0.6,0.8,1,1",
			price               = 130,
			mana                = 23,
			action 		        = function()
									c.fire_rate_wait = c.fire_rate_wait + 7
									c.screenshake = c.screenshake + 1
									shot_effects.recoil_knockback = shot_effects.recoil_knockback + 10.0

				                    add_projectile( "mods/noita.hardmod/files/modules/spell_variety/entities/spells/echo_shot.xml" )
			                    end,
		},
		{
			id                  = "HARDMOD_ECHO_SHOT_TIMER",
			name 		        = "$hardmod_spell_echo_shot_timer_name",
			description         = "$hardmod_spell_echo_shot_timer_desc",
			sprite              = "mods/noita.hardmod/files/modules/spell_variety/gfx/ui_gfx/spells/echo_shot_timer.png",
			related_projectiles	= { "mods/noita.hardmod/files/modules/spell_variety/entities/spells/echo_shot.xml" },
			type 		        = ACTION_TYPE_PROJECTILE,
			spawn_level         = "1,2,3,4",
			spawn_probability   = "0.5,0.5,0.5,1",
			price               = 160,
			mana                = 35,
			action 		        = function()
									c.fire_rate_wait = c.fire_rate_wait + 7
									c.screenshake = c.screenshake + 1
									shot_effects.recoil_knockback = shot_effects.recoil_knockback + 10.0

				                    add_projectile_trigger_timer( "mods/noita.hardmod/files/modules/spell_variety/entities/spells/echo_shot.xml", 9, 1 )
			                    end,
		},
	    {
		    id                  = "HARDMOD_CONTROLLED_REACH",
		    name 		        = "$hardmod_controlled_reach_name",
		    description         = "$hardmod_controlled_reach_desc",
		    sprite 		        = "mods/noita.hardmod/files/modules/spell_variety/gfx/ui_gfx/spells/controlled_reach.png",
		    type 		        = ACTION_TYPE_MODIFIER,
			spawn_level         = "1,2,3,4,5,6", -- 2/3 of RECHARGE
			spawn_probability   = "0.5,0.6,0.7,0.5,0.6,0.7", -- 2/3 of RECHARGE
			related_extra_entities = { "mods/D2DContentPack/files/entities/projectiles/deck/controlled_reach.xml" },
		    price               = 330,
		    mana                = 3,
		    action              = function()
		    						-- for the tooltip
									c.fire_rate_wait = c.fire_rate_wait - 10
									current_reload_time = current_reload_time - 20
									if reflecting then return end
									c.fire_rate_wait = c.fire_rate_wait + 10
									current_reload_time = current_reload_time + 20

									-- add entity that controls the spell's reach
									c.extra_entities = c.extra_entities .. "mods/noita.hardmod/files/modules/spell_variety/entities/spells/controlled_reach.xml,"

									-- determine the distance
									dofile_once( "data/scripts/lib/utilities.lua" )
									local ox, oy = EntityGetTransform( GetUpdatedEntityID() )
									local mx, my = DEBUG_GetMouseWorld()
									local dist = get_distance( ox, oy, mx, my )

									-- increase fire rate and projectile speed based on distance
									local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" )
									local buff_ratio = utils.Remap( dist, 180, 65, 0.1, 1.0 )
									c.fire_rate_wait = c.fire_rate_wait - ( 10 * buff_ratio )
									current_reload_time = current_reload_time - ( 20 * buff_ratio )
									c.speed_multiplier = c.speed_multiplier * ( 1.5 + ( 1.0 * buff_ratio ) )

									-- finally, draw the next spell
				                    draw_actions( 1, true )
		                        end,
	    },
		{
			id					= "HARDMOD_BIG_SHOT",
			name				= "$hardmod_spell_big_shot_name",
			description			= "$hardmod_spell_big_shot_desc",
			sprite				= "mods/noita.hardmod/files/modules/spell_variety/gfx/ui_gfx/spells/big_shot.png",
			type				= ACTION_TYPE_MODIFIER,
			spawn_level         = "2,3,4,5,6",
			spawn_probability   = "0.2,0.3,0.4,0.5,0.6",
			price				= 200,
			mana				= 50,
			custom_xml_file		= "mods/noita.hardmod/files/modules/spell_variety/entities/cards/card_big_shot.xml",
			action				= function()
				                    current_reload_time = current_reload_time + 25
									shot_effects.recoil_knockback = shot_effects.recoil_knockback + 200.0

									if reflecting then return end

									c.extra_entities = c.extra_entities .. "mods/noita.hardmod/files/modules/spell_variety/entities/spells/big_shot.xml,"
									c.extra_entities = c.extra_entities .. "data/entities/particles/tinyspark_yellow.xml,"

				                    draw_actions( 1, true )
								end,
		},
		{
			id                  = "HARDMOD_RECHARGE_SHIELD",
			name 		        = "$hardmod_spell_recharge_shield_name",
			description         = "$hardmod_spell_recharge_shield_desc",
			sprite              = "mods/noita.hardmod/files/modules/spell_variety/gfx/ui_gfx/spells/recharge_shield.png",
			type 		        = ACTION_TYPE_PASSIVE,
			spawn_level         = "1,2,3,4,5,6", -- ENERGY_SHIELD
			spawn_probability   = "0.2,0.4,0.8,0.4,0.4,0.6", -- ~ENERGY_SHIELD
			price               = 220,
			mana                = 10,
			custom_xml_file 	= "mods/noita.hardmod/files/modules/spell_variety/entities/cards/card_recharge_shield.xml",
			action 		        = function()
									draw_actions( 1, true )
			                    end,
		},
	}
}
