local hooks = {
	func = function() end, --Runs code, code in raw init will run twice, code here will only run once.
	new_spells = {}, --Indexed table of spells to add to `actions`, runs after `func`.
	spell_patches = {}, --Table of spells to modify keyed by spell ID, runs after new spells are added.
	edit_spell = function(spell) end, --Runs for every spell in `actions`, runs after patches are applied.
}