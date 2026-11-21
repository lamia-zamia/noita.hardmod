local hooks = {}---@type perk_hooks

hooks.perk_patches = {
	NO_MORE_SHUFFLE = {
		not_in_default_perk_pool = true,
		not_progress = true,
	}
}

return hooks
