local hooks = {
	func = function() end, --Runs code, code in raw init will run twice, code here will only run once.
	new_perks = {}, --Indexed table of perks to add to `perk_list`, runs after `func`.
	perk_patches = {}, --Table of perks to modify keyed by perk ID, runs after new perks are added.
	edit_perk = function(perk) end, --Runs for every perk in `perk_list`, runs after patches are applied.
}