---@diagnostic disable: undefined-global

local hooks = {}

dofile_once("mods/noita.hardmod/files/modules/rapidfire_nerfs/scripts/null_mana.lua")

local mana_reducing_spells = { "MANA_REDUCE", "HARDMOD_MANA_REDUCE", "APOTHEOSIS_WATER_POWER" }

hooks.spell_patches = {
	["CHAINSAW"] = {
		spawn_level	   = "4,5,6,10",
		spawn_probability = "0.8,0.9,1,1",
		price			 = 160,
		mana			  = 12,
		action = function()
			add_projectile("data/entities/projectiles/deck/chainsaw.xml")
			c.fire_rate_wait = 0
			c.spread_degrees = c.spread_degrees + 6.0
			current_reload_time = current_reload_time - 3
		end
	},
	["MANA_REDUCE"] = {
		description = "$hardmod_spell_add_mana_desc",
		spawn_level = "3,4,5,6,10",
		spawn_probability = "0.8,0.9,0.9,1,1",
		price = 160,
		mana = -15,
		action = function()
			c.fire_rate_wait = c.fire_rate_wait + 7
			current_reload_time = current_reload_time + 2
			draw_actions(1, true)
		end
	},
	["SLOW_BUT_STEADY"] = {
		description = "$hardmod_spell_slow_but_steady_desc",
		mana = -40,
		action = function ()
			current_reload_time = math.max(90, current_reload_time)
			shot_effects.recoil_knockback = shot_effects.recoil_knockback - 100.0
			draw_actions(1, true)
		end
	},
	["SPREAD_REDUCE"] = {
		mana = 2,
		action = function ()
			c.spread_degrees = c.spread_degrees - 15.0
			draw_actions(1, true)
		end
	},
	["HEAVY_SPREAD"] = {
		description = "$hardmod_spell_heavy_spread_desc",
		mana   = 6,
		sprite = "mods/noita.hardmod/files/modules/rapidfire_nerfs/ui_gfx/heavy_spread.png",
		action = function()
			-- parity with cheeseless_triggers
			c.spread_degrees = c.spread_degrees + 12
			c.fire_rate_wait = c.fire_rate_wait - 6
			current_reload_time = current_reload_time - 10
			draw_actions(1, true)
		end,
	},
	["DIGGER"] = {
		mana = 6,
		action = function()
			add_projectile("data/entities/projectiles/deck/digger.xml")
			c.fire_rate_wait = c.fire_rate_wait + 2
			c.spread_degrees = c.spread_degrees + 4.0
			current_reload_time = current_reload_time - 10
		end,
	},
	["APOTHEOSIS_WATER_POWER"] = {
		description = "$hardmod_spell_apotheosis_water_power_desc",
		mana		= 0,
		action  = function()
			draw_actions( 1, true )

			if reflecting or GameGetGameEffectCount( GetUpdatedEntityID(), "WET" ) > 0 then
				c.fire_rate_wait	= c.fire_rate_wait - 10
				current_reload_time = current_reload_time - 20

				local ctrlcomp = EntityGetFirstComponentIncludingDisabled( GetUpdatedEntityID(), "ControlsComponent" )
				if ctrlcomp then
					local fire_frame = ComponentGetValue2( ctrlcomp, "mButtonFrameFire" )
					local current_frame = GameGetFrameNum()

					local frames_firing = current_frame - fire_frame
					local burst_duration = 20
					local max_restore = 0
					if frames_firing < burst_duration then
						max_restore = ( ( 50 / burst_duration ) * ( burst_duration - frames_firing ) )
					end

					local hand_cost = 0
					local mana_reducing_spell_count = 1
					for i,v in ipairs( hand ) do
						if v.mana ~= nil then
							hand_cost = hand_cost + v.mana
						end
						for i,id in ipairs( mana_reducing_spells ) do
							if id == v.id then
								mana_reducing_spell_count = mana_reducing_spell_count + 1
							end
						end
					end
					hand_cost = hand_cost / mana_reducing_spell_count

					local restore = math.min( hand_cost, max_restore )
					mana = mana + restore
				end
			end
		end,
	},
}

hooks.new_spells = {
	{
		id = "HARDMOD_NULL_MANA",
		name = "$hardmod_spell_null_mana_name",
		description = "$hardmod_spell_null_mana_desc",
		sprite = "mods/noita.hardmod/files/modules/rapidfire_nerfs/ui_gfx/null_mana.png",
		type = ACTION_TYPE_MODIFIER,
		spawn_level = "2,3,4,5,6",
		spawn_probability = "0.6,0.8,0.9,1,1",
		price = 160,
		mana = -20,
		action = function()
			c.fire_rate_wait = c.fire_rate_wait + 6
			current_reload_time = current_reload_time + 1
			HardmodActionNullMana()
			draw_actions(1, true)
		end
	},
	{
		id				  = "HARDMOD_MANA_REDUCE",
		name				= "$hardmod_spell_mana_reduce_name",
		description		 = "$hardmod_spell_mana_reduce_desc",
		sprite			  = "mods/noita.hardmod/files/modules/rapidfire_nerfs/ui_gfx/add_mana.png",
		type				= ACTION_TYPE_MODIFIER,
		spawn_level		 = "1,2,3,4,5,6",
		spawn_probability   = "0.7,0.9,1,1,1,1",
		price			   = 160,
		mana				= 0,
		action = function()
			draw_actions( 1, true )

			local ctrlcomp = EntityGetFirstComponentIncludingDisabled( GetUpdatedEntityID(), "ControlsComponent" )
			if ctrlcomp then
				local fire_frame = ComponentGetValue2( ctrlcomp, "mButtonFrameFire" )
				local current_frame = GameGetFrameNum()

				local frames_firing = current_frame - fire_frame
				local burst_duration = 20
				local max_restore = 0
				if frames_firing < burst_duration then
					max_restore = ( ( 50 / burst_duration ) * ( burst_duration - frames_firing ) )
				end

				local hand_cost = 0
				local mana_reducing_spell_count = 1
				for i,v in ipairs( hand ) do
					if v.mana ~= nil then
						hand_cost = hand_cost + v.mana
					end
					for i,id in ipairs( mana_reducing_spells ) do
						if v.id == id then
							mana_reducing_spell_count = mana_reducing_spell_count + 1
						end
					end
				end
				hand_cost = hand_cost / mana_reducing_spell_count

				local restore = math.min( hand_cost, max_restore )
				mana = mana + restore
			end
		end,
	},
	{
		id				  = "HARDMOD_MINI_CHAINSAW",
		name				= "$hardmod_spell_mini_chainsaw_name",
		description		 = "$hardmod_spell_mini_chainsaw_desc",
		sprite			  = "mods/noita.hardmod/files/modules/rapidfire_nerfs/ui_gfx/mini_chainsaw.png",
		related_projectiles = { "mods/noita.hardmod/files/modules/rapidfire_nerfs/entities/chainsaw_mini.xml" },
		type				= ACTION_TYPE_PROJECTILE,
		spawn_level		 = "1,2,3,4",
		spawn_probability   = "0.7,0.8,0.9,0.9",
		price			   = 80,
		mana				= 6,
		sound_loop_tag	  = "sound_chainsaw",
		action			  = function()
			add_projectile("mods/noita.hardmod/files/modules/rapidfire_nerfs/entities/chainsaw_mini.xml")
			c.fire_rate_wait = c.fire_rate_wait * 0.5
			c.spread_degrees = c.spread_degrees + 6.0
			current_reload_time = current_reload_time - 3
		end,
	},
	{
		id				  = "HARDMOD_SPELL_MANA_REGEN",
		name				= "$hardmod_spell_mana_regen_name",
		description		 = "$hardmod_spell_mana_regen_desc",
		sprite			  = "mods/noita.hardmod/files/modules/rapidfire_nerfs/ui_gfx/mana_regen.png",
		type				= ACTION_TYPE_PASSIVE,
		spawn_level		 = "1,2,3,4,5,6", -- MANA_REDUCE
		spawn_probability   = "0.7,0.9,1,1,1,1", -- MANA_REDUCE
		price			   = 100,
		mana				= 0,
		custom_xml_file	 = "mods/noita.hardmod/files/modules/rapidfire_nerfs/entities/card_mana_regen.xml",
		action = function()
			draw_actions( 1, true )
		end,
	},
}

hooks.edit_spell = function(spell)
	if spell.spawn_requires_flag == "card_unlocked_paint" then
		-- they're still very good, but you have to do a quest to get them
		spell.spawn_level = ""
		spell.spawn_probability = "0"
		spell.mana = 3

		--local orig_action = action.action
		--action.action = function()
		--	orig_action()
		--	c.fire_rate_wait = c.fire_rate_wait + 2
		--end
	end
end

return hooks
