local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local cast_price = utils.GetInternalInt(GetUpdatedEntityID(), "hardmod_indulgence_cast_price")

local offsetx = 6
local text = tostring(cast_price)
local textwidth = 0
for i=1,#text do
	local l = string.sub(text, i, i)

	if l ~= "1" then textwidth = textwidth + 6
	else textwidth = textwidth + 3 end
end

offsetx = textwidth * 0.5 - 0.5

EntityAddComponent2(GetUpdatedEntityID(), "SpriteComponent", {
	_tags = "enabled_in_world",
	image_file = "mods/noita.hardmod/files/modules/limited_spells/gfx/fonts/font_small_numbers_with_hyphen.xml",
	is_text_sprite = true,
	offset_x = offsetx,
	offset_y = 8,
	text = "-" .. tostring(cast_price or 0),
	z_index = -1,
})
