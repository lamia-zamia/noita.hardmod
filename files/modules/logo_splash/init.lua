-- Overengineered logo splash thingy

local rotatable_text = dofile_once("mods/noita.hardmod/files/modules/logo_splash/rotatable_text.lua") ---@type rotatable_text
local menu_tracker = dofile_once("mods/noita.hardmod/files/modules/logo_splash/menu_tracker.lua") ---@type menu_tracker
local death_tracker = dofile_once("mods/noita.hardmod/files/modules/logo_splash/death_tracker.lua") ---@type death_tracker
local splashes = dofile_once("mods/noita.hardmod/files/modules/logo_splash/splashes.lua") ---@type (string|splash_entry)[]
local death_splashes = dofile_once("mods/noita.hardmod/files/modules/logo_splash/splash_death.lua") ---@type (string|splash_entry)[]

local year,month,day,hour,minute,second = GameGetDateAndTimeLocal()
--math.randomseed(second + minute * hour) --seed this off smth

local FONT = "data/fonts/font_pixel.xml"
local TEXT_ANGLE = math.rad(20)
local TEXT_SCALE = 1.5
local TEXT_COLOR = { r = 1, g = 1, b = 0, a = 1 } ---@type rotatable_text_color
local SCREEN_MARGIN = 4
-- Nudges the splash center off the logo's right-edge midpoint; tuned by eye.
local ANCHOR_OFFSET_X = 8
local ANCHOR_OFFSET_Y = 20
local FIRST_GLYPH_ID = 1000

---@class splash_pool
---@field splashes (string|splash_entry)[]
---@field queue integer[] indices left to show before any of them repeats
---@field current integer index of the splash shown last

local pause_pool = { splashes = splashes, queue = {}, current = 0 } ---@type splash_pool
local death_pool = { splashes = death_splashes, queue = {}, current = 0 } ---@type splash_pool

local gui = GuiCreate()
local shown_pool = nil ---@type splash_pool?
local frame = 0
local draw_options = { scale = 1, font = FONT, z = -1000000 } ---@type rotatable_text_options

---@class splash_layout_part
---@field text string?
---@field image string?
---@field color rotatable_text_color?
---@field font string?
---@field scale number
---@field width number
---@field height number
---@field center number distance from the part's top to its visual center

---@class splash_layout_line
---@field parts splash_layout_part[]
---@field width number
---@field height number
---@field center number distance from the line's top to the center its parts share
---@field below number distance from that center to the line's bottom

-- Lines and their scale-1 sizes only change on reroll; the per-frame pulse just multiplies them.
local lines = {} ---@type splash_layout_line[]
local block_width = 0
local block_height = 0
local splash_scale = 1
local splash_speed = 1
local splash_angle = TEXT_ANGLE

-- The glyph sprites must be generated while ModTextFileSetContent is still available.
rotatable_text.prepare(FONT)
for _, pool in ipairs({ pause_pool, death_pool }) do
	for _, splash in ipairs(pool.splashes) do
		if type(splash) == "table" then
			if splash.font then rotatable_text.prepare(splash.font) end
			for _, part in ipairs(splash) do
				if type(part) == "table" and part.font then rotatable_text.prepare(part.font) end
			end
		end
	end
end

---Picks a random splash index from a pool, never repeating the current one.
---@param pool splash_pool
---@return integer
local function pick_splash_index(pool)
	if #pool.queue < 1 then
		for idx,_ in ipairs(pool.splashes) do
			table.insert(pool.queue, idx)
		end
	end

	local idx = math.random(1, #pool.queue)
	local splash = pool.queue[idx]

	if splash == pool.current and #pool.queue > 1 then
		return pick_splash_index(pool)
	end

	table.remove(pool.queue, idx)

	return splash
end

---Starts an empty line; one left empty takes no space, so blank lines collapse.
local function start_line()
	lines[#lines + 1] = { parts = {}, width = 0, height = 0, center = 0, below = 0 }
end

---Adds a part to the last line.
---@param part splash_layout_part
local function add_to_line(part)
	local line = lines[#lines]
	line.parts[#line.parts + 1] = part
	line.width = line.width + part.width
	line.center = math.max(line.center, part.center)
	line.below = math.max(line.below, part.height - part.center)
	line.height = line.center + line.below
end

---Measures an image part and adds it to the last line.
---@param part splash_part
local function add_image(part)
	local scale = part.scale or 1
	local width, height = GuiGetImageDimensions(gui, part.image, scale)
	add_to_line({ image = part.image, color = part.color, scale = scale, width = width, height = height, center = height / 2 })
end

---Measures one line's worth of a text part and adds it to the last line.
---@param text string
---@param part splash_part
---@param entry splash_entry
local function add_text(text, part, entry)
	local font = part.font or entry.font or FONT
	local scale = part.scale or 1
	local _, metrics = rotatable_text.prepare(font)
	add_to_line({
		text = text,
		color = part.color or entry.color or TEXT_COLOR,
		font = font,
		scale = scale,
		width = rotatable_text.advance(text, font) * scale,
		height = metrics.line_height * scale,
		center = metrics.glyph_height / 2 * scale,
	})
end

---Splits a splash into lines of parts and measures them at scale 1.
---@param splash string|splash_entry
local function layout_splash(splash)
	local entry = type(splash) == "string" and { splash } or splash
	lines = {}
	block_width, block_height = 0, 0
	splash_scale, splash_speed, splash_angle = entry.scale or 1, entry.speed or 1, entry.angle or TEXT_ANGLE
	start_line()
	for _, part in ipairs(entry) do
		if type(part) == "string" then part = { part } end
		if part.image then
			add_image(part)
		else
			for text, newline in part[1]:gmatch("([^\n]*)(\n?)") do
				if text ~= "" then add_text(text, part, entry) end
				if newline ~= "" then start_line() end
			end
		end
	end
	for _, line in ipairs(lines) do
		block_width = math.max(block_width, line.width)
		block_height = block_height + line.height
	end
end

---Returns the start coordinate that keeps a block inside the screen margin, favoring the top/left edge when it cannot fit.
---@param position number
---@param size number
---@param screen_size number
---@return number
local function clamp_to_screen(position, size, screen_size)
	return math.max(SCREEN_MARGIN, math.min(screen_size - SCREEN_MARGIN - size, position))
end

---Draws the splash lines centered on the logo's bottom right corner with a pulsing scale AND ROTATION.
---@param logo_right number
---@param logo_middle number
---@param screen_width number
---@param screen_height number
local function draw_splash(logo_right, logo_middle, screen_width, screen_height)
    frame = frame + 1
    local scale = (TEXT_SCALE + math.sin(frame * 0.1 * splash_speed) * 0.1) * splash_scale

    local width = block_width * scale
    local height = block_height * scale
    local block_x = clamp_to_screen(logo_right + ANCHOR_OFFSET_X - width / 2, width, screen_width)
    local block_y = clamp_to_screen(logo_middle + ANCHOR_OFFSET_Y - height / 2, height, screen_height)

    local center_x = block_x + width / 2
    local center_y = block_y + height / 2

    local angle = math.sin(frame * 0.01 * splash_speed) * splash_angle -- radians
    local cos_a, sin_a = math.cos(angle), math.sin(angle)

    local glyph_id = FIRST_GLYPH_ID
    local line_y = block_y
    for _, line in ipairs(lines) do
        local part_x = block_x + (block_width - line.width) / 2 * scale
        for _, part in ipairs(line.parts) do
            -- Every part on a line shares one vertical center.
            local part_y = line_y + (line.center - part.center) * scale

            local dx, dy = part_x - center_x, part_y - center_y
            local rot_x = center_x + dx * cos_a - dy * sin_a
            local rot_y = center_y + dx * sin_a + dy * cos_a
			-- hope you don't mind me making this shit actively worse but i needed it to rotate left and right

            draw_options.scale = scale * part.scale
            draw_options.color = part.color
            draw_options.font = part.font
            if part.image then
                glyph_id = rotatable_text.draw_image(gui, glyph_id, rot_x, rot_y, part.image, angle, draw_options)
            else
                glyph_id = rotatable_text.draw(gui, glyph_id, rot_x, rot_y, part.text, angle, draw_options)
            end

            part_x = part_x + part.width * scale
        end
        line_y = line_y + line.height * scale
    end
end

---Draw
---@param paused boolean
local function update(paused)
	GuiStartFrame(gui)
	local screen_width, screen_height = GuiGetScreenDimensions(gui)
	local pool, logo_right, logo_middle = nil, 0, 0
	if menu_tracker.should_show_splash() then
		pool = pause_pool
		logo_right, logo_middle = menu_tracker.logo_right_middle()
	elseif not paused and death_tracker.should_show_splash() then
		pool = death_pool
		logo_right, logo_middle = death_tracker.logo_right_middle(gui, screen_width, screen_height)
	end
	if pool and pool ~= shown_pool then
		pool.current = pick_splash_index(pool)
		layout_splash(pool.splashes[pool.current])
	end
	shown_pool = pool
	if pool then draw_splash(logo_right, logo_middle, screen_width, screen_height) end
	menu_tracker.draw(gui, screen_width, screen_height)
end

return {
	-- Runs unpaused too, so GuiStartFrame clears the splash left over from the last paused frame.
	pre_update = function() update(false) end,
	pause_pre_update = function()
		-- Pausing after death has to clear the death splash even when the tracker wants no redraw.
		if menu_tracker.pause_pre_update() or death_tracker.player_died then update(true) end
	end,
	pause_changed = menu_tracker.pause_changed,
	player_destroyed = death_tracker.player_destroyed,
	count_secrets = function(total, found)
		menu_tracker.count_secrets()
		return total, found
	end,
}
