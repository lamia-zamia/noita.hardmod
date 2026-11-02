---@diagnostic disable: undefined-global

return {
	new_spells = {
		{
			id = "HARDMOD_BROKEN_SPELL",
			name = "$action_broken_spell",
			description = "$hardmod_spell_broken_spell_desc",
			sprite = "data/items_gfx/broken_spell.png",
			sprite_unidentified = "data/ui_gfx/gun_actions/spread_reduce_unidentified.png",
			type = ACTION_TYPE_OTHER,
			spawn_probability = "0",
			not_progress = true,
			mana = 0,
			action = function()
				if reflecting then return end
				-- todo: it'd be funny to actually turn this into a usable projectile or smth
				local player = GetUpdatedEntityID()
				LoadGameEffectEntityTo(player, "data/entities/misc/effect_electricity.xml")
				EntityInflictDamage(player, 0.2, "DAMAGE_ELECTRICITY", "broken spell", "NORMAL", 0, 0)
			end
		}
	}
}
