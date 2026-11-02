---@class rotatable_text_glyph
---@field x number atlas x
---@field y number atlas y
---@field w number atlas width
---@field h number atlas height
---@field advance number pen advance
---@field animation string RectAnimation name in the generated sprite

---@class rotatable_text_metrics
---@field texture string font atlas path
---@field line_height number
---@field glyph_height number tallest glyph cell; the letters sit around its middle, usually lower than `line_height / 2`
---@field char_space number width and advance used for codepoints the font lacks
---@field space_width number
---@field glyphs table<integer, rotatable_text_glyph>

---@class rotatable_text_color
---@field r number? `1` red, 0 to 1
---@field g number? `1` green, 0 to 1
---@field b number? `1` blue, 0 to 1
---@field a number? `1` alpha, 0 to 1

---@class rotatable_text_options
---@field scale number? `1` scale factor applied to glyphs
---@field font string? `data/fonts/font_pixel.xml` font XML path
---@field glyph_angle number? per-glyph rotation in radians (defaults to `angle`)
---@field alpha number? `1` alpha for each glyph
---@field z number? z-index for each glyph
---@field color rotatable_text_color? tint color

---@class rotatable_text
local rotatable_text = {}

local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

local DEFAULT_FONT = "data/fonts/font_pixel.xml"
local SPRITE_DIRECTORY = "mods/noita.hardmod/vfs/fonts/"
local SPACE = 32
-- GUI_RECT_ANIMATION_PLAYBACK.Loop from data/scripts/lib/utilities.lua.
local ANIMATION_LOOP = 2
local NO_OPTIONS = {} ---@type rotatable_text_options

local sprite_paths = {} ---@type table<string, string>
local font_metrics = {} ---@type table<string, rotatable_text_metrics>
local codepoint_cache = {} ---@type table<string, integer[]>

---Returns the payload bits and byte length of a UTF-8 sequence from its lead byte.
---@param lead_byte integer
---@return integer payload
---@return integer length
local function decode_lead_byte(lead_byte)
	if lead_byte < 0x80 then return lead_byte, 1 end
	if bit.band(lead_byte, 0xE0) == 0xC0 then return bit.band(lead_byte, 0x1F), 2 end
	if bit.band(lead_byte, 0xF0) == 0xE0 then return bit.band(lead_byte, 0x0F), 3 end
	if bit.band(lead_byte, 0xF8) == 0xF0 then return bit.band(lead_byte, 0x07), 4 end
	return 0xFFFD, 1
end

---Decodes UTF-8 text into codepoints, memoized because the same splash lines are drawn every frame.
---@param text string
---@return integer[]
local function codepoints(text)
	local cached = codepoint_cache[text]
	if cached then return cached end

	local result = {}
	local byte_index = 1
	local length = #text
	while byte_index <= length do
		local codepoint, sequence_length = decode_lead_byte(string.byte(text, byte_index))
		for offset = 1, sequence_length - 1 do
			local continuation = string.byte(text, byte_index + offset)
			if continuation then codepoint = codepoint * 64 + continuation - 0x80 end
		end
		result[#result + 1] = codepoint
		byte_index = byte_index + sequence_length
	end
	codepoint_cache[text] = result
	return result
end

---Returns the trimmed text content of the first child with the given tag.
---@param font_xml element
---@param tag_name string
---@return string
local function tag_text(font_xml, tag_name)
	return table.concat(font_xml:first_of(tag_name).content or {}):match("^%s*(.-)%s*$")
end

---Parses one QuadChar element's attributes into a glyph.
---@param attributes table<string, string>
---@param id integer
---@param line_height number
---@return rotatable_text_glyph
local function parse_glyph(attributes, id, line_height)
	local width = tonumber(attributes.rect_w) or 0
	if width == 0 then width = tonumber(attributes.width) or 0 end
	return {
		x = tonumber(attributes.rect_x) or 0,
		y = tonumber(attributes.rect_y) or 0,
		w = width,
		h = tonumber(attributes.rect_h) or line_height,
		advance = tonumber(attributes.width) or width,
		animation = tostring(id),
	}
end

---Parses a font XML into glyph metrics.
---@param font_path string
---@return rotatable_text_metrics
local function parse_font(font_path)
	local font_xml = nxml.parse_file(font_path)
	local line_height = tonumber(tag_text(font_xml, "LineHeight")) or 8
	local glyphs = {}
	local glyph_height = 0
	for quad in font_xml:each_of("QuadChar") do
		local id = tonumber(quad.attr.id)
		if id then
			glyphs[id] = parse_glyph(quad.attr, id, line_height)
			glyph_height = math.max(glyph_height, glyphs[id].h)
		end
	end
	local space = glyphs[SPACE]
	return {
		texture = tag_text(font_xml, "Texture"),
		line_height = line_height,
		glyph_height = glyph_height,
		char_space = tonumber(tag_text(font_xml, "CharSpace")) or 0,
		space_width = space and space.advance or tonumber(tag_text(font_xml, "WordSpace")) or 4,
		glyphs = glyphs,
	}
end

---Builds a sprite XML with one RectAnimation per glyph, so GuiImage can draw any glyph rotated.
---@param metrics rotatable_text_metrics
---@return string
local function build_sprite_xml(metrics)
	local sprite = nxml.new_element("Sprite", {
		filename = metrics.texture,
		offset_x = "0",
		offset_y = "0",
		default_animation = "32",
	})
	for _, glyph in pairs(metrics.glyphs) do
		sprite:add_child(nxml.new_element("RectAnimation", {
			name = glyph.animation,
			pos_x = tostring(glyph.x),
			pos_y = tostring(glyph.y),
			frame_count = "1",
			frame_width = tostring(glyph.w),
			frame_height = tostring(glyph.h),
			frame_wait = "0.1",
			frames_per_row = "1",
			loop = "1",
		}))
	end
	return nxml.tostring(sprite)
end

---Returns the unscaled pen advance for a codepoint.
---@param metrics rotatable_text_metrics
---@param codepoint integer
---@param glyph rotatable_text_glyph?
---@return number
local function advance_of(metrics, codepoint, glyph)
	if codepoint == SPACE then return metrics.space_width end
	return glyph and glyph.advance or metrics.char_space
end

---Applies z and tint to the next widget.
---@param gui gui
---@param opts rotatable_text_options
local function style_next_widget(gui, opts)
	if opts.z then GuiZSetForNextWidget(gui, opts.z) end
	local color = opts.color
	if color then GuiColorSetForNextWidget(gui, color.r or 1, color.g or 1, color.b or 1, color.a or 1) end
end

---Generates the per-glyph sprite for a font; the first call per font must happen during mod init.
---@param font_path string? `data/fonts/font_pixel.xml`
---@return string sprite_path virtual sprite XML path used by GuiImage
---@return rotatable_text_metrics metrics
function rotatable_text.prepare(font_path)
	font_path = font_path or DEFAULT_FONT
	local sprite_path = sprite_paths[font_path]
	if sprite_path then return sprite_path, font_metrics[font_path] end

	local metrics = parse_font(font_path)
	sprite_path = SPRITE_DIRECTORY .. (font_path:gsub("[^%w%.%-_]", "_"))
	ModTextFileSetContent(sprite_path, build_sprite_xml(metrics))
	sprite_paths[font_path] = sprite_path
	font_metrics[font_path] = metrics
	return sprite_path, metrics
end

---Measures the bounding box of rotated text; the result scales linearly with `scale`.
---Glyphs rotate around their top-left corner, so they can stick out left of or above the draw origin;
---draw at `box_x + origin_x, box_y + origin_y` to place the box's top-left corner at `box_x, box_y`.
---@param text string? text to measure
---@param angle number? baseline angle in radians (`0`)
---@param scale number? scale factor (`1`)
---@param font_path string? font XML path (`data/fonts/font_pixel.xml`)
---@param glyph_angle number? per-glyph rotation in radians (defaults to `angle`)
---@return number width
---@return number height
---@return number origin_x draw origin offset from the box's left edge
---@return number origin_y draw origin offset from the box's top edge
---@nodiscard
function rotatable_text.measure(text, angle, scale, font_path, glyph_angle)
	angle = angle or 0
	glyph_angle = glyph_angle or angle
	local _, metrics = rotatable_text.prepare(font_path)
	local glyphs = metrics.glyphs
	local cos_angle, sin_angle = math.cos(angle), math.sin(angle)
	local cos_glyph, sin_glyph = math.cos(glyph_angle), math.sin(glyph_angle)

	local pen = 0
	local min_x, min_y, max_x, max_y = 0, 0, 0, 0
	for _, codepoint in ipairs(codepoints(text or "")) do
		local glyph = glyphs[codepoint]
		local width = glyph and glyph.w or metrics.char_space
		local height = glyph and glyph.h or metrics.line_height
		-- The glyph's width edge runs along (cos, sin) and its height edge along (-sin, cos).
		local width_x, width_y = width * cos_glyph, width * sin_glyph
		local height_x, height_y = -height * sin_glyph, height * cos_glyph
		local pen_x, pen_y = pen * cos_angle, pen * sin_angle
		min_x = math.min(min_x, pen_x + math.min(0, width_x) + math.min(0, height_x))
		max_x = math.max(max_x, pen_x + math.max(0, width_x) + math.max(0, height_x))
		min_y = math.min(min_y, pen_y + math.min(0, width_y) + math.min(0, height_y))
		max_y = math.max(max_y, pen_y + math.max(0, width_y) + math.max(0, height_y))
		pen = pen + advance_of(metrics, codepoint, glyph)
	end
	scale = scale or 1
	return (max_x - min_x) * scale, (max_y - min_y) * scale, -min_x * scale, -min_y * scale
end

---Returns the unscaled pen advance of a whole text, where anything drawn after it should start.
---@param text string? text to measure
---@param font_path string? font XML path (`data/fonts/font_pixel.xml`)
---@return number
---@nodiscard
function rotatable_text.advance(text, font_path)
	local _, metrics = rotatable_text.prepare(font_path)
	local pen = 0
	for _, codepoint in ipairs(codepoints(text or "")) do
		pen = pen + advance_of(metrics, codepoint, metrics.glyphs[codepoint])
	end
	return pen
end

---Draws rotated text with one GuiImage per visible glyph; returns the next free widget id.
---@param gui gui game GUI handle
---@param id integer first widget id, one is consumed per visible glyph
---@param x number origin x
---@param y number origin y
---@param text string? text to draw
---@param angle number? baseline angle in radians (`0`)
---@param opts rotatable_text_options? draw options
---@return integer next_id
function rotatable_text.draw(gui, id, x, y, text, angle, opts)
	opts = opts or NO_OPTIONS
	angle = angle or 0
	local scale = opts.scale or 1
	local glyph_angle = opts.glyph_angle or angle
	local alpha = opts.alpha or 1
	local sprite_path, metrics = rotatable_text.prepare(opts.font)
	local glyphs = metrics.glyphs
	local step_x, step_y = math.cos(angle) * scale, math.sin(angle) * scale

	local pen = 0
	for _, codepoint in ipairs(codepoints(text or "")) do
		local glyph = glyphs[codepoint]
		if glyph and codepoint ~= SPACE then
			style_next_widget(gui, opts)
			GuiImage(gui, id, x + pen * step_x, y + pen * step_y, sprite_path, alpha, scale, scale, glyph_angle, ANIMATION_LOOP, glyph.animation)
			id = id + 1
		end
		pen = pen + advance_of(metrics, codepoint, glyph)
	end
	return id
end

---Draws a rotated image with the same options as text; returns the next free widget id.
---@param gui gui game GUI handle
---@param id integer widget id
---@param x number origin x
---@param y number origin y
---@param image string image path
---@param angle number? rotation in radians (`0`)
---@param opts rotatable_text_options? draw options; `font` and `glyph_angle` are ignored
---@return integer next_id
function rotatable_text.draw_image(gui, id, x, y, image, angle, opts)
	opts = opts or NO_OPTIONS
	local scale = opts.scale or 1
	style_next_widget(gui, opts)
	GuiImage(gui, id, x, y, image, opts.alpha or 1, scale, scale, angle or 0)
	return id + 1
end

return rotatable_text
