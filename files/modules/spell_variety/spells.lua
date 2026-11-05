---@diagnostic disable: undefined-global

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
			id                  = "D2D_ECHO_SHOT_TIMER",
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
	}
}
