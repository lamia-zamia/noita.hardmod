return {
	new_perks = {
		{
			id = "HARDMOD_ALEPH",
			ui_name = "$hardmod_perk_aleph_name",
			ui_description = "$hardmod_perk_aleph_desc",
			ui_icon = "mods/noita.hardmod/files/modules/limited_spells/gfx/perk_aleph_016.png",
			perk_icon = "mods/noita.hardmod/files/modules/limited_spells/gfx/perk_aleph.png",
			stackable = false,
			one_off_effect = false,
			usable_by_enemies = false,
			not_in_default_perk_pool = true,
			func = function()
				GameAddFlagRun("HARDMOD_HAS_ALEPH_PERK")
			end,
			func_remove = function()
				GameRemoveFlagRun("HARDMOD_HAS_ALEPH_PERK")
			end,
		},
	},
	perk_patches = {
		["UNLIMITED_SPELLS"] = {
			not_in_default_perk_pool = true,
			not_progress = true,
		}
	}
}
