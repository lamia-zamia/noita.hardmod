-- Reconstructs the vanilla pause-menu route from input and invisible copies of its widgets.
-- Someone please kill me, this is too much

---@alias menu_state "closed"|"pending"|"main"|"submenu"
---@alias submenu_kind "newgame"|"progress"|"options"|"mods"|"release_notes"|"credits"|"unknown"
---@alias input_device "keyboard"|"gamepad"
---@alias return_cause "back"|"click"|"accept"

---@class menu_tracker
---@field last_pause_was_inventory boolean
---@field awaiting_return_release boolean whether the input that left a submenu is still held
---@field menu_state menu_state
---@field pending_pause_frames integer frames spent waiting for the pause key after a pause began
---@field pause_input_type input_device device the native menu lays itself out for
---@field focused_main_row integer
---@field main_focus_from_navigation boolean whether the native menu shows keyboard/gamepad focus
---@field navigation_repeat_frames integer frames until a held direction repeats
---@field hovered_main_row integer?
---@field hovered_return boolean
---@field help_image_x number on-screen position of the invisible help image probe
---@field help_image_y number
---@field submenu_kind submenu_kind? "unknown" means the depth was lost; it waits for a resync
---@field submenu_nested boolean a click inside New Game or Mods may have opened a screen on top of it
---@field progress_drawn boolean OnCountSecrets ran since the last paused update
---@field progress_confirmed boolean the Progress screen has drawn since it was entered
---@field progress_wait_frames integer paused updates spent waiting for a predicted Progress screen
---@field progress_exit_cause return_cause last input seen while Progress was open
---@field progress_exit_gamepad boolean whether that input came from a gamepad
---@field debug_menu_tracker boolean
---@field debug_last_click string
local tracker = {
	last_pause_was_inventory = false,
	awaiting_return_release = false,
	menu_state = "closed",
	pending_pause_frames = 0,
	pause_input_type = "keyboard",
	focused_main_row = 1,
	main_focus_from_navigation = false,
	navigation_repeat_frames = 0,
	hovered_main_row = nil,
	hovered_return = false,
	help_image_x = 0,
	help_image_y = 0,
	submenu_kind = nil,
	submenu_nested = false,
	progress_drawn = false,
	progress_confirmed = false,
	progress_wait_frames = 0,
	progress_exit_cause = "accept",
	progress_exit_gamepad = false,
	debug_menu_tracker = false,
	debug_last_click = "none",
}

-- data/scripts/lib/utilities.lua
local GUI_OPTION_ALIGN_HORIZONTAL_CENTER = 16

-- data/scripts/debug/keycodes.lua
local KEY_RETURN = 40
local KEY_ESCAPE = 41
local KEY_KP_ENTER = 88
local KEY_DOWN = 81
local KEY_UP = 82
local JOY_DPAD_UP = 11
local JOY_DPAD_DOWN = 12
local JOY_START = 15
local JOY_BACK = 16
local JOY_A = 23
local JOY_B = 24
local JOY_LEFT_STICK_UP = 41
local JOY_LEFT_STICK_DOWN = 42

local PENDING_PAUSE_MAX_FRAMES = 2
-- A predicted Progress screen first draws one paused update after the click; give up after two.
local PROGRESS_CONFIRM_FRAMES = 2
local NAVIGATION_REPEAT_DELAY = 18
local NAVIGATION_REPEAT_INTERVAL = 5
local DEBUG_Z = -1000100

local HELP_IMAGE_ID = 9800
local FOOTER_PROBE_ID = 9801
-- One id per main row, offset by the row index
local MAIN_ROW_PROBE_ID = 9810

local ROW_CONTINUE = 1
local ROW_PROGRESS = 3
local ROW_OPTIONS = 4
local ROW_MODS = 5
local ROW_SAVE_AND_QUIT = 8
local MAIN_MENU_KEYS = {
	"$menu_continue",
	"$menu_newgame",
	"$menu_progress",
	"$menu_options",
	"$menu_mods",
	"$menu_releasenotes",
	"$menu_credits",
	"$menu_saveandquit",
}
local MAIN_ROW_COUNT = #MAIN_MENU_KEYS
local SUBMENU_BY_ROW = { [2] = "newgame", [3] = "progress", [5] = "mods", [6] = "release_notes", [7] = "credits" }
-- Screens whose Return button sits at the shared bottom-left position.
local RETURN_BUTTON_KINDS = { newgame = true, mods = true, credits = true }
-- Screens that can open further screens (dialogs, world select, mod settings) on top of themselves.
local NESTING_KINDS = { newgame = true, mods = true }
local HELP_IMAGES = {
	keyboard = "data/ui_gfx/pause_menu/help_keyboardmouse.png",
	gamepad = "data/ui_gfx/pause_menu/help_gamepad360.png",
}
-- The pause menu has no separate logo widget; the logo is baked into the help image. Pixel bounds measured from the PNGs.
local HELP_IMAGE_LOGO_BOUNDS = {
	keyboard = { top = 4, bottom = 71, right = 225 },
	gamepad = { top = 12, bottom = 79, right = 213 },
}
-- Release Notes Return y: layout top at 10% height, then a 280-high scroll box with 2 units of padding at both ends, the layout's -2 margin and 8 units of spacing.
local RELEASE_NOTES_TOP = 0.1
local RELEASE_NOTES_RETURN_OFFSET = 290

local main_labels = {} ---@type string[]
-- Rows whose label the engine can swap for a wider one Lua cannot predict; the probe covers both.
local alt_main_labels = {} ---@type table<integer, string>
local menu_top_percent = nil ---@type number?

---@class menu_input
---@field back boolean the native back action: an Escape key press or a gamepad Start press
---@field left_click boolean released this frame, since native GUI buttons act on release
---@field controller_accept boolean
---@field accept boolean
---@field keyboard_direction boolean whether the direction came from the keyboard
---@field up boolean
---@field down boolean
local input = {
	back = false,
	left_click = false,
	controller_accept = false,
	accept = false,
	keyboard_direction = false,
	up = false,
	down = false,
}

---Returns whether a gamepad button is held.
---@param button integer
---@return boolean
local function joystick_down(button)
	return InputIsJoystickButtonDown(0, button)
end

---Returns whether a gamepad button was pressed this frame.
---@param button integer
---@return boolean
local function joystick_just_down(button)
	return InputIsJoystickButtonJustDown(0, button)
end

---Returns whether the pause key is held on keyboard or gamepad.
---@return boolean
local function pause_open_input_down()
	return InputIsKeyDown(KEY_ESCAPE) or InputIsKeyJustDown(KEY_ESCAPE) or joystick_down(JOY_START) or joystick_just_down(JOY_START)
end

---Returns whether the native back action was pressed this frame.
---@return boolean
local function back_pressed()
	return InputIsKeyJustDown(KEY_ESCAPE) or joystick_just_down(JOY_START)
end

---Returns whether any gamepad menu button was pressed this frame.
---@return boolean
local function gamepad_navigation_input()
	return joystick_just_down(JOY_START)
		or joystick_just_down(JOY_BACK)
		or joystick_just_down(JOY_A)
		or joystick_just_down(JOY_B)
		or joystick_just_down(JOY_DPAD_UP)
		or joystick_just_down(JOY_DPAD_DOWN)
		or joystick_just_down(JOY_LEFT_STICK_UP)
		or joystick_just_down(JOY_LEFT_STICK_DOWN)
end

---Translates the main-menu labels; redone on every entry so a language change in Options applies.
local function refresh_main_labels()
	for row = 1, MAIN_ROW_COUNT do
		main_labels[row] = GameTextGet(MAIN_MENU_KEYS[row])
	end
	-- "Progress ($0 new)" counts per-run flags over a directory listing Lua cannot enumerate;
	alt_main_labels[ROW_PROGRESS] = GameTextGet("$menu_progress_new", "999")
	-- "Mods (!)" depends on mod compatibility data Lua cannot read.
	alt_main_labels[ROW_MODS] = GameTextGet("$menu_mods_incompatibilities")
end

---Counts down the held-direction repeat; returns the repeated up/down press when it fires.
---@param up_held boolean
---@param down_held boolean
---@return boolean up
---@return boolean down
local function repeat_held_direction(up_held, down_held)
	tracker.navigation_repeat_frames = tracker.navigation_repeat_frames - 1
	if tracker.navigation_repeat_frames > 0 then return false, false end
	tracker.navigation_repeat_frames = NAVIGATION_REPEAT_INTERVAL
	return up_held, not up_held and down_held
end

---Samples up/down presses, turning a held direction into repeats like the native menu.
local function read_direction()
	local keyboard_up_held = InputIsKeyDown(KEY_UP)
	local keyboard_down_held = InputIsKeyDown(KEY_DOWN)
	local up_held = keyboard_up_held or joystick_down(JOY_DPAD_UP) or joystick_down(JOY_LEFT_STICK_UP)
	local down_held = keyboard_down_held or joystick_down(JOY_DPAD_DOWN) or joystick_down(JOY_LEFT_STICK_DOWN)
	local up = InputIsKeyJustDown(KEY_UP) or joystick_just_down(JOY_DPAD_UP) or joystick_just_down(JOY_LEFT_STICK_UP)
	local down = InputIsKeyJustDown(KEY_DOWN) or joystick_just_down(JOY_DPAD_DOWN) or joystick_just_down(JOY_LEFT_STICK_DOWN)

	if up or down then
		tracker.navigation_repeat_frames = NAVIGATION_REPEAT_DELAY
	elseif up_held or down_held then
		up, down = repeat_held_direction(up_held, down_held)
	else
		tracker.navigation_repeat_frames = 0
	end
	input.keyboard_direction = keyboard_up_held or keyboard_down_held
	input.up = up
	input.down = down
end

---Samples this frame's menu input into the shared input table.
local function read_input()
	input.back = back_pressed()
	input.left_click = InputIsMouseButtonJustUp(1)
	input.controller_accept = joystick_just_down(JOY_A)
	input.accept = input.controller_accept or InputIsKeyJustDown(KEY_RETURN) or InputIsKeyJustDown(KEY_KP_ENTER)
	read_direction()
end

---Returns whether a submenu's Return button was activated this frame.
---@return boolean
local function submenu_return_clicked()
	return (input.left_click or input.controller_accept) and tracker.hovered_return
end

---Records the last click for the debug overlay.
local function record_debug_click()
	local mouse_x, mouse_y = InputGetMousePosOnScreen()
	tracker.debug_last_click = string.format("%.0f,%.0f (%s, footer=%s)", mouse_x, mouse_y, tracker.menu_state, tostring(submenu_return_clicked()))
end

---Opens the main menu like a fresh pause does: Continue selected but without visible focus.
local function open_main_menu()
	tracker.menu_state = "main"
	tracker.submenu_kind = nil
	tracker.submenu_nested = false
	tracker.focused_main_row = ROW_CONTINUE
	tracker.main_focus_from_navigation = false
	tracker.pause_input_type = joystick_down(JOY_START) and "gamepad" or "keyboard"
	tracker.awaiting_return_release = false
	refresh_main_labels()
end

---Marks the pause menu as closed.
local function close_menu()
	tracker.menu_state = "closed"
	tracker.submenu_kind = nil
	tracker.submenu_nested = false
end

---Moves the model onto a submenu.
---@param kind submenu_kind
local function enter_submenu(kind)
	tracker.menu_state = "submenu"
	tracker.submenu_kind = kind
	tracker.submenu_nested = false
	if kind == "progress" then
		tracker.progress_confirmed = false
		tracker.progress_wait_frames = 0
		tracker.progress_exit_cause = "accept"
		tracker.progress_exit_gamepad = false
	end
end

---Returns to the main menu, restoring the focus the native menu shows after that kind of exit.
---@param cause return_cause
---@param used_gamepad boolean
local function return_to_main(cause, used_gamepad)
	tracker.menu_state = "main"
	tracker.submenu_kind = nil
	tracker.submenu_nested = false
	tracker.pause_input_type = used_gamepad and "gamepad" or "keyboard"
	tracker.awaiting_return_release = true
	if cause == "back" then
		-- The native menu restores Continue focus after Escape/Start.
		tracker.focused_main_row = ROW_CONTINUE
		tracker.main_focus_from_navigation = true
	elseif cause == "click" then
		tracker.focused_main_row = ROW_CONTINUE
		tracker.main_focus_from_navigation = false
	end
	refresh_main_labels()
end

---Waits a few frames for the pause key to register; returns whether the main menu opened.
---Only Escape/Start set the pause flag; another paused screen (the replay editor) never shows the key.
---@return boolean
local function resolve_pending_pause()
	if pause_open_input_down() then
		open_main_menu()
		return true
	end
	tracker.pending_pause_frames = tracker.pending_pause_frames + 1
	if tracker.pending_pause_frames > PENDING_PAUSE_MAX_FRAMES then close_menu() end
	return false
end

---Moves the simulated focus; the first press only reveals focus on Continue.
local function navigate_main_menu()
	tracker.pause_input_type = input.keyboard_direction and "keyboard" or "gamepad"
	if not tracker.main_focus_from_navigation then
		tracker.main_focus_from_navigation = true
		tracker.focused_main_row = ROW_CONTINUE
		return
	end
	local step = input.down and 1 or -1
	tracker.focused_main_row = math.max(1, math.min(MAIN_ROW_COUNT, tracker.focused_main_row + step))
end

---Returns the main-menu row activated this frame, if any.
---@return integer?
local function activated_main_row()
	-- The native menu ignores Enter/A until a direction has given it focus.
	local row = tracker.main_focus_from_navigation and tracker.focused_main_row or nil
	if input.up or input.down then
		navigate_main_menu()
		row = tracker.focused_main_row
	end
	if input.left_click then
		row = tracker.hovered_main_row
		if row then
			tracker.focused_main_row = row
			tracker.main_focus_from_navigation = false
		end
	end
	if input.left_click or input.accept then return row end
	return nil
end

---Applies a main-menu activation: Continue and Save & Quit close the menu, other rows open their submenu.
---@param row integer
local function activate_main_row(row)
	if row == ROW_CONTINUE or row == ROW_SAVE_AND_QUIT then
		-- Closing now keeps the splash from lingering for a frame after the menu disappears.
		close_menu()
		return
	end
	if input.controller_accept then tracker.pause_input_type = "gamepad" end
	-- Options is entered by the OnPausedChanged it raises, which also reports its exit.
	if row == ROW_OPTIONS then return end
	enter_submenu(SUBMENU_BY_ROW[row])
end

---Leaves New Game, Mods, Release Notes or Credits on Escape/Start or their Return button.
local function update_submenu()
	if not (input.back or submenu_return_clicked()) then
		if NESTING_KINDS[tracker.submenu_kind] and (input.left_click or input.accept) then
			tracker.submenu_nested = true
		end
		return
	end
	if tracker.submenu_nested then
		-- The press may have closed a screen opened on top instead; wait for a resync.
		tracker.submenu_kind = "unknown"
		return
	end
	return_to_main(input.back and "back" or input.left_click and "click" or "accept", gamepad_navigation_input())
end

---Follows the Progress screen by its OnCountSecrets calls: confirms a predicted entry, and returns
---to the main menu once a paused update passes without one.
---@param drawn boolean
local function update_progress(drawn)
	if input.back or input.left_click or input.accept then
		tracker.progress_exit_cause = input.back and "back" or input.left_click and "click" or "accept"
		tracker.progress_exit_gamepad = gamepad_navigation_input()
	end
	if drawn then
		tracker.progress_confirmed = true
		return
	end
	if tracker.progress_confirmed then
		return_to_main(tracker.progress_exit_cause, tracker.progress_exit_gamepad)
		return
	end
	tracker.progress_wait_frames = tracker.progress_wait_frames + 1
	if tracker.progress_wait_frames >= PROGRESS_CONFIRM_FRAMES then
		-- The click missed the native label; the base menu never left.
		tracker.menu_state = "main"
		tracker.submenu_kind = nil
	end
end

---After leaving a submenu via Escape/Start/A, holds the splash back until that key is released,
---since the native main menu only reappears after the tracker has already seen the press.
local function update_return_release()
	if InputIsKeyDown(KEY_ESCAPE) or joystick_down(JOY_START) or joystick_down(JOY_A) then return end
	tracker.awaiting_return_release = false
end

---Returns the shared bottom-left Return button position of the New Game, Mods and Credits screens.
---@param screen_width number
---@param screen_height number
---@return number x
---@return number y
local function return_position(screen_width, screen_height)
	return screen_width * 0.04, screen_height * 0.93
end

---Tints the next probe cyan above everything in debug mode.
---@param gui gui
local function color_probe(gui)
	if not tracker.debug_menu_tracker then return end
	GuiZSetForNextWidget(gui, DEBUG_Z)
	GuiColorSetForNextWidget(gui, 0.1, 1, 1, 1)
end

---Tints a main-menu probe row in debug mode, highlighting focus and Continue.
---@param gui gui
---@param row integer
local function color_main_row(gui, row)
	if not tracker.debug_menu_tracker then return end
	GuiZSetForNextWidget(gui, DEBUG_Z)
	if tracker.main_focus_from_navigation and row == tracker.focused_main_row then
		GuiColorSetForNextWidget(gui, 1, 1, 0.2, 1)
	elseif row == ROW_CONTINUE then
		GuiColorSetForNextWidget(gui, 1, 0.3, 0.3, 1)
	else
		GuiColorSetForNextWidget(gui, 0.1, 1, 1, 1)
	end
end

---Returns UI_PAUSE_MENU_LAYOUT_TOP_EDGE_PERCENTAGE, read once since magic numbers are fixed after init.
---@return number
local function get_menu_top_percent()
	menu_top_percent = menu_top_percent or tonumber(MagicNumbersGetValue("UI_PAUSE_MENU_LAYOUT_TOP_EDGE_PERCENTAGE")) or 10
	return menu_top_percent
end

---Draws a box and returns whether it is hovered; invisible unless debugging.
---@param gui gui
---@param id integer
---@param x number
---@param y number
---@param width number
---@param height number
---@return boolean
local function probe_box(gui, id, x, y, width, height)
	GuiImageNinePiece(gui, id, x, y, width, height, tracker.debug_menu_tracker and 1 or 0)
	local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
	return hovered
end

-- Scratch tables reused every frame for the main-row probe positions
local row_centers_x = {} ---@type number[]
local row_tops_y = {} ---@type number[]

---Rebuilds the native main-menu layout with invisible widgets to detect the hovered row.
---@param gui gui
---@param screen_width number
---@param screen_height number
local function probe_main_menu(gui, screen_width, screen_height)
	-- The native top offset is display-scaled and truncated
	local offset_factor = tracker.pause_input_type == "gamepad" and 0.25 or 1
	local menu_top = math.floor(get_menu_top_percent() * offset_factor) * 0.01
	GuiLayoutBeginVertical(gui, screen_width * 0.5, screen_height * menu_top, true, 4, 0)
	-- The help image
	GuiOptionsAddForNextWidget(gui, GUI_OPTION_ALIGN_HORIZONTAL_CENTER)
	GuiImage(gui, HELP_IMAGE_ID, 0, 0, HELP_IMAGES[tracker.pause_input_type], 0, 1, 1, 0, 0, "")
	local _, _, _, image_x, image_y = GuiGetPreviousWidgetInfo(gui)
	tracker.help_image_x, tracker.help_image_y = image_x, image_y
	-- Blank lines reproduce the native row heights; the probes go on top after the layout closes
	GuiText(gui, 0, 0, " ", 1)
	for row = 1, MAIN_ROW_COUNT do
		GuiOptionsAddForNextWidget(gui, GUI_OPTION_ALIGN_HORIZONTAL_CENTER)
		GuiText(gui, 0, 0, " ", 1)
		local _, _, _, x, y, width = GuiGetPreviousWidgetInfo(gui)
		row_centers_x[row], row_tops_y[row] = x + width / 2, y
	end
	GuiLayoutEnd(gui)

	for row = 1, MAIN_ROW_COUNT do
		-- Both labels are centered on the row, so the wider one covers the narrower.
		local label_width, label_height = GuiGetTextDimensions(gui, main_labels[row], 1)
		local alt_label = alt_main_labels[row]
		if alt_label then label_width = math.max(label_width, (GuiGetTextDimensions(gui, alt_label, 1))) end
		color_main_row(gui, row)
		if probe_box(gui, MAIN_ROW_PROBE_ID + row, row_centers_x[row] - label_width / 2, row_tops_y[row], label_width, label_height) then
			tracker.hovered_main_row = row
		end
	end
end

---Probes the Return button of the open submenu, if its position is known.
---@param gui gui
---@param screen_width number
---@param screen_height number
local function probe_submenu(gui, screen_width, screen_height)
	local kind = tracker.submenu_kind
	if tracker.submenu_nested then return end
	local label = GameTextGet("$menu_return")
	local label_width, label_height = GuiGetTextDimensions(gui, label, 1)
	if RETURN_BUTTON_KINDS[kind] then
		local x, y = return_position(screen_width, screen_height)
		color_probe(gui)
		tracker.hovered_return = probe_box(gui, FOOTER_PROBE_ID, x, y, label_width, label_height)
	elseif kind == "release_notes" then
		-- Return's x is the left edge of the centered release-notes text, whose width Lua cannot
		-- measure, so the probe covers the whole row up to the screen center.
		local y = screen_height * RELEASE_NOTES_TOP + RELEASE_NOTES_RETURN_OFFSET
		color_probe(gui)
		tracker.hovered_return = probe_box(gui, FOOTER_PROBE_ID, 0, y, screen_width * 0.5 + label_width, label_height)
	end
end

---Describes the open submenu for the debug overlay.
---@return string
local function submenu_debug_text()
	local kind = tracker.submenu_kind
	if kind == "progress" then
		return string.format("Progress: confirmed %s, waited %d", tostring(tracker.progress_confirmed), tracker.progress_wait_frames)
	end
	if kind == "options" then return "Options: exit reported by OnPausedChanged" end
	if kind == "unknown" then return "Lost depth: waiting for unpause or Progress to resync" end
	return string.format("%s: nested %s, Return hovered %s", kind, tostring(tracker.submenu_nested), tostring(tracker.hovered_return))
end

---Draws the tracker state as text.
---@param gui gui
---@param screen_height number
local function draw_debug_overlay(gui, screen_height)
	if tracker.menu_state == "submenu" and tracker.submenu_kind then
		GuiZSetForNextWidget(gui, DEBUG_Z)
		GuiText(gui, 8, screen_height * 0.8, submenu_debug_text(), 1)
	end
	local mouse_x, mouse_y = InputGetMousePosOnScreen()
	local status = string.format(
		"splash tracker: %s | hovered row %s | focus row %s | mouse %.0f,%.0f | last click %s",
		tracker.menu_state,
		tracker.hovered_main_row or "none",
		tracker.main_focus_from_navigation and tracker.focused_main_row or "none",
		mouse_x,
		mouse_y,
		tracker.debug_last_click
	)
	GuiZSetForNextWidget(gui, DEBUG_Z)
	GuiText(gui, 8, 8, status, 1)
end

---Returns the on-screen midpoint of the logo's right edge inside the help image, as of the last main-menu probe.
---@return number right
---@return number middle
function tracker.logo_right_middle()
	local bounds = HELP_IMAGE_LOGO_BOUNDS[tracker.pause_input_type]
	return tracker.help_image_x + bounds.right, tracker.help_image_y + (bounds.top + bounds.bottom) / 2
end

---Draws the hover probes for the current menu, plus the debug overlay when enabled.
---@param gui gui
---@param screen_width number
---@param screen_height number
function tracker.draw(gui, screen_width, screen_height)
	tracker.hovered_main_row = nil
	tracker.hovered_return = false
	if tracker.menu_state == "main" then
		probe_main_menu(gui, screen_width, screen_height)
	elseif tracker.menu_state == "submenu" then
		probe_submenu(gui, screen_width, screen_height)
	end
	if tracker.debug_menu_tracker then draw_debug_overlay(gui, screen_height) end
end

---Returns whether the main pause menu is showing, so the splash should be too.
---@return boolean
function tracker.should_show_splash()
	return tracker.menu_state == "main" and not tracker.awaiting_return_release
end

---Classifies an Options exit: Apply & Return is pressed during the menu draw, after this frame's
---input was sampled; Escape/Start are handled before the paused update.
---@return return_cause
local function options_exit_cause()
	if back_pressed() then return "back" end
	if input.left_click then return "click" end
	if input.accept then return "accept" end
	return "back"
end

---OnPausedChanged handler. Besides real pauses it fires when Options opens and when it closes,
---including Options opened from New Game or Mods, which reports only its close.
---@param is_paused boolean
---@param is_inventory_pause boolean
function tracker.pause_changed(is_paused, is_inventory_pause)
	tracker.last_pause_was_inventory = is_inventory_pause
	if not is_paused or is_inventory_pause then
		close_menu()
		return
	end
	local state = tracker.menu_state
	if state == "closed" or state == "pending" then
		if pause_open_input_down() then
			open_main_menu()
		else
			tracker.menu_state = "pending"
			tracker.submenu_kind = nil
			tracker.pending_pause_frames = 0
		end
	elseif state == "main" or (tracker.submenu_kind == "progress" and not tracker.progress_confirmed) then
		-- An unconfirmed Progress prediction means the activation actually landed on Options.
		enter_submenu("options")
	elseif tracker.submenu_kind == "options" then
		return_to_main(options_exit_cause(), gamepad_navigation_input())
	elseif NESTING_KINDS[tracker.submenu_kind] then
		-- Options opened from this screen closed back onto it.
		tracker.submenu_nested = false
	else
		tracker.submenu_kind = "unknown"
	end
end

---OnCountSecrets handler; the engine calls it on every frame it draws the Progress screen.
function tracker.count_secrets()
	tracker.progress_drawn = true
	if tracker.menu_state == "submenu" and tracker.submenu_kind == "progress" then return end
	-- While paused Progress is only reachable from the main menu, so this also resyncs a model that lost track.
	enter_submenu("progress")
	tracker.progress_confirmed = true
end

---OnPausePreUpdate handler; returns whether the splash GUI needs a redraw this frame.
---@return boolean
function tracker.pause_pre_update()
	if tracker.last_pause_was_inventory then return false end
	local progress_drawn = tracker.progress_drawn
	tracker.progress_drawn = false
	if tracker.menu_state == "closed" then return tracker.debug_menu_tracker end
	if tracker.menu_state == "pending" and not resolve_pending_pause() then return false end

	read_input()
	if tracker.awaiting_return_release then update_return_release() end
	if input.left_click and tracker.debug_menu_tracker then record_debug_click() end
	local kind = tracker.submenu_kind
	if tracker.menu_state == "main" then
		local row = activated_main_row()
		if row then activate_main_row(row) end
	elseif kind == "progress" then
		update_progress(progress_drawn)
	elseif kind ~= "options" and kind ~= "unknown" then
		update_submenu()
	end
	return true
end

return tracker
