local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml
local deck = "data/entities/projectiles/deck/"

local hooks = {}---@type hooks

-- matter eaten't
local matter_eatent_list = {
	rock_hard_border = true,
	-- templebrick_static = true,
	-- templebrick_noedge_static = true,
}
local durability_override = {
	rock_hard_border = 16,
	rock_static_cursed = 16,
}

function hooks.edit_material(mat)
	local name = mat.attr.name

	if matter_eatent_list[name] then
		local tags = mat.attr.tags
		tags = tags and (tags .. ",") or ""
		mat.attr.tags = tags .. "[matter_eater_ignore_list]"
	end
	if durability_override[name] then
		mat:set("durability", durability_override[name])
	end
end

return hooks
