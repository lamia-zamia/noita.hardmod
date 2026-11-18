local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

local root = "mods/noita.hardmod/files/modules/spell_variety/"

return {
	new_spells = {
		{
			id = "HARDMOD_NOTLA",
			name = "$hardmod_spell_notla_name",
			description = "$hardmod_spell_notla_desc",
			sprite = root.."gfx/ui_gfx/spells/notla.png",
			related_extra_entities = { root.."entities/spells/notla.xml" },
			type = ACTION_TYPE_MODIFIER,
			spawn_level= "2,4,5,6,10",
			spawn_probability = "0.2,0.2,0.5,0.5,1",
			price = 50,
			mana = 3,
			action = function()
				c.extra_entities = c.extra_entities .. root.."entities/spells/notla.xml,"
				c.fire_rate_wait = c.fire_rate_wait - 10
				draw_actions(1, true)
			end
		},
		{
			id                  = "HARDMOD_ECHO_SHOT",
			name 		        = "$hardmod_spell_echo_shot_name",
			description         = "$hardmod_spell_echo_shot_desc",
			sprite              = root.."gfx/ui_gfx/spells/echo_shot.png",
			related_projectiles	= { root.."entities/spells/echo_shot.xml" },
			type 		        = ACTION_TYPE_PROJECTILE,
			spawn_level         = "2,3,4",
			spawn_probability   = "0.4,0.6,0.6",
			price               = 130,
			mana                = 23,
			action = function()
				c.fire_rate_wait = c.fire_rate_wait + 7
				c.screenshake = c.screenshake + 1
				shot_effects.recoil_knockback = shot_effects.recoil_knockback + 10.0

				add_projectile(root.."entities/spells/echo_shot.xml")
			end,
		},
		{
			id                  = "HARDMOD_ECHO_SHOT_TIMER",
			name 		        = "$hardmod_spell_echo_shot_timer_name",
			description         = "$hardmod_spell_echo_shot_timer_desc",
			sprite              = root.."gfx/ui_gfx/spells/echo_shot_timer.png",
			related_projectiles	= { root.."entities/spells/echo_shot.xml" },
			type 		        = ACTION_TYPE_PROJECTILE,
			spawn_level         = "2,3,4",
			spawn_probability   = "0.3,0.5,0.5",
			price               = 160,
			mana                = 35,
			action = function()
				c.fire_rate_wait = c.fire_rate_wait + 7
				c.screenshake = c.screenshake + 1
				shot_effects.recoil_knockback = shot_effects.recoil_knockback + 10.0

				add_projectile_trigger_timer(root.."entities/spells/echo_shot.xml", 9, 1)
			end,
		},
	    {
		    id                  = "HARDMOD_CONTROLLED_REACH",
		    name 		        = "$hardmod_controlled_reach_name",
		    description         = "$hardmod_controlled_reach_desc",
		    sprite 		        = root.."gfx/ui_gfx/spells/controlled_reach.png",
		    type 		        = ACTION_TYPE_MODIFIER,
			spawn_level         = "1,2,3,4,5",
			spawn_probability   = "0.2,0.4,0.4,0.3,0.5",
			related_extra_entities = { root.."entities/spells/controlled_reach.xml" },
		    price               = 165,
		    mana                = 4,
		    action = function()
				-- for the tooltip
				c.fire_rate_wait = c.fire_rate_wait - 10
				current_reload_time = current_reload_time - 20

				-- add entity that controls the spell's reach
				c.extra_entities = c.extra_entities .. root.."entities/spells/controlled_reach.xml,"

				if reflecting then return end
				-- reset; initial -10 -20 was just for the tooltip, pls no delet this
				c.fire_rate_wait = c.fire_rate_wait + 10
				current_reload_time = current_reload_time + 20

				-- determine the distance
				dofile_once("data/scripts/lib/utilities.lua")
				local ox, oy = EntityGetTransform(GetUpdatedEntityID())
				local mx, my = DEBUG_GetMouseWorld()
				local dist = get_distance(ox, oy, mx, my)

				-- if this spell is part of a trigger payload, don't raise the wand's fire rate
				-- (there might be more performant ways to do this)
				local apply_boost = true
				for _,card in ipairs( hand ) do
					if card.type == ACTION_TYPE_PROJECTILE
						and ( string.find( card.id, "TRIGGER" ) or string.find( card.id, "TIMER" ) ) then
						apply_boost = false
					end
				end
				-- increase fire rate and projectile speed based on distance
				if apply_boost then
					local buff_ratio = utils.Remap(dist, 180, 65, 0.1, 1.0)
					c.fire_rate_wait = c.fire_rate_wait - (10 * buff_ratio)
					current_reload_time = current_reload_time - (20 * buff_ratio)
					c.speed_multiplier = c.speed_multiplier * (1.5 + (1.0 * buff_ratio))
				end

				-- finally, draw the next spell
				draw_actions(1, true)
			end,
	    },
		{
			id					= "HARDMOD_BIG_SHOT",
			name				= "$hardmod_spell_big_shot_name",
			description			= "$hardmod_spell_big_shot_desc",
			sprite				= root.."gfx/ui_gfx/spells/big_shot.png",
			type				= ACTION_TYPE_MODIFIER,
			spawn_level         = "3,4,5,6",
			spawn_probability   = "0.3,0.4,0.5,0.6",
			price				= 200,
			mana				= 50,
			custom_xml_file		= root.."entities/cards/card_big_shot.xml",
			action = function()
				current_reload_time = current_reload_time + 25
				shot_effects.recoil_knockback = shot_effects.recoil_knockback + 200.0

				c.extra_entities = c.extra_entities .. root.."entities/spells/big_shot.xml,"
				c.extra_entities = c.extra_entities .. "data/entities/particles/tinyspark_yellow.xml,"

				draw_actions(1, true)
			end,
		},
		{
			id                  = "HARDMOD_RECHARGE_SHIELD",
			name 		        = "$hardmod_spell_recharge_shield_name",
			description         = "$hardmod_spell_recharge_shield_desc",
			sprite              = root.."gfx/ui_gfx/spells/recharge_shield.png",
			type 		        = ACTION_TYPE_PASSIVE,
			spawn_level         = "1,2,3,4,5,6",
			spawn_probability   = "0.3,0.4,0.6,0.4,0.5,0.7",
			price               = 220,
			mana                = 20,
			custom_xml_file 	= root.."entities/cards/card_recharge_shield.xml",
			action = function()
				draw_actions(1, true)
			end,
		},
		{
			id					= "HARDMOD_PARRY",
			name				= "$hardmod_spell_parry_name",
			description			= "$hardmod_spell_parry_desc",
			sprite				= "mods/noita.hardmod/files/modules/trial_perks/gfx/ui_gfx/spells/parry.png",
			related_projectiles	= { "mods/noita.hardmod/files/modules/trial_perks/entities/spells/parry.xml" },
			type				= ACTION_TYPE_STATIC_PROJECTILE,
			spawn_level			= "2,3,4", -- HEAL_BULLET
			spawn_probability	= "0.6,0.6,0.4", -- HEAL_BULLET
			price				= 220,
			mana				= 20,
			max_uses			= 20,
			never_unlimited		= true,
			action = function()
				c.fire_rate_wait = c.fire_rate_wait + 48
				if reflecting then return end

				local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" )
				local prev_cast_frame = utils.GetInternalInt( GetUpdatedEntityID(), "hardmod_parry_prev_cast_frame" ) or 0
				local current_frame = GameGetFrameNum()
				if current_frame - prev_cast_frame > 48 then
					add_projectile( "mods/noita.hardmod/files/modules/trial_perks/entities/spells/parry.xml" )
					utils.SetInternalInt( GetUpdatedEntityID(), "hardmod_parry_prev_cast_frame", current_frame )
				else
					local x, y = EntityGetTransform( GetUpdatedEntityID() )
                    GamePlaySound( "data/audio/Desktop/items.bank", "magic_wand/not_enough_mana_for_action", x, y )
                    add_projectile( "data/entities/projectiles/deck/fizzle.xml" )
				end
			end,
		},
	}
}
