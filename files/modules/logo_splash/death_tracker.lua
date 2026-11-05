-- Follows the vanilla game-over screen: invisible copies of its layout find the title and New Game.

---@alias death_screen "game_over"|"new_game"|"lost"

---@class death_tracker
---@field player_died boolean OnPlayerDied ran
---@field screen death_screen "lost" means the depth is unknown; it waits for a pause to resync
---@field stats_may_show boolean an input that can reveal the stats and buttons has been seen
---@field new_game_hovered boolean
---@field return_hovered boolean
---@field submenu_nested boolean a click inside New Game may have opened a screen on top of it
---@field progress_drawn boolean OnCountSecrets ran since the last update
---@field progress_open boolean the Progress screen drew last frame
---@field logo_right number on-screen midpoint of the title's right edge, as of the last draw
---@field logo_middle number
---@field debug_death_tracker boolean
local tracker = {
	player_died = false,
	screen = "game_over",
	stats_may_show = false,
	new_game_hovered = false,
	return_hovered = false,
	submenu_nested = false,
	progress_drawn = false,
	progress_open = false,
	logo_right = 0,
	logo_middle = 0,
	debug_death_tracker = false,
}

-- data/scripts/lib/utilities.lua
local GUI_OPTION_ALIGN_HORIZONTAL_CENTER = 16

-- data/scripts/debug/keycodes.lua
local KEY_RETURN = 40
local KEY_ESCAPE = 41
local KEY_SPACE = 44
local KEY_KP_ENTER = 88
local JOY_START = 15
local JOY_A = 23

local TITLE_PROBE_ID = 9830
local NEW_GAME_PROBE_ID = 9831
local RETURN_PROBE_ID = 9832
local DEBUG_Z = -1000100
local LAYOUT_MARGIN_X = 4
local LAYOUT_MARGIN_Y = 0
local TITLE_IMAGE = "data/ui_gfx/game_over_menu/game_over.png"
-- Vertical offset once the title has settled; for its first 0.77 seconds it rises into place from 15 lower.
local TITLE_OFFSET_Y = -3
-- Cause of death, mods enabled, gold, time, depth, places, enemies, max HP, items, total deaths, total wins.
-- Any active mod (this one) adds the mods row and removes the streaks row.
local FIXED_STAT_ROWS = 11
local BUTTONS_SPACING_Y = 8

local layout_top_percent = nil ---@type number?

---Returns UI_GAME_OVER_MENU_LAYOUT_TOP_EDGE_PERCENTAGE
---@return number
local function get_layout_top_percent()
	layout_top_percent = layout_top_percent or tonumber(MagicNumbersGetValue("UI_GAME_OVER_MENU_LAYOUT_TOP_EDGE_PERCENTAGE")) or 19
	return layout_top_percent
end

---Returns whether the screen for a lost run is up. A won run shows the same screen with another title.
---@return boolean
local function lost_run_screen_up()
	return tracker.player_died and not GameHasFlagRun("ending_game_completed") and not GameHasFlagRun("ending_no_game_over_menu")
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
	if tracker.debug_death_tracker then
		GuiZSetForNextWidget(gui, DEBUG_Z)
		GuiColorSetForNextWidget(gui, 0.1, 1, 1, 1)
	end
	GuiImageNinePiece(gui, id, x, y, width, height, tracker.debug_death_tracker and 1 or 0)
	local _, _, hovered = GuiGetPreviousWidgetInfo(gui)
	return hovered
end

---Rebuilds the native layout to record the title's position and detect the hovered New Game button.
---@param gui gui
---@param screen_width number
---@param screen_height number
local function probe_game_over(gui, screen_width, screen_height)
	GuiLayoutBeginVertical(gui, screen_width * 0.5, screen_height * get_layout_top_percent() * 0.01, true, LAYOUT_MARGIN_X, LAYOUT_MARGIN_Y)
	GuiOptionsAddForNextWidget(gui, GUI_OPTION_ALIGN_HORIZONTAL_CENTER)
	GuiImage(gui, TITLE_PROBE_ID, 0, TITLE_OFFSET_Y, TITLE_IMAGE, 0, 1, 1, 0, 0, "")
	local _, _, _, title_x, title_y, title_width, title_height = GuiGetPreviousWidgetInfo(gui)
	tracker.logo_right, tracker.logo_middle = title_x + title_width, title_y + title_height / 2
	-- Blank lines reproduce the native row heights.
	for _ = 1, FIXED_STAT_ROWS + (GameGetOrbCountThisRun() > 0 and 1 or 0) do
		GuiText(gui, 0, 0, " ", 1)
	end
	GuiLayoutAddVerticalSpacing(gui, BUTTONS_SPACING_Y)
	GuiOptionsAddForNextWidget(gui, GUI_OPTION_ALIGN_HORIZONTAL_CENTER)
	GuiText(gui, 0, 0, " ", 1)
	local _, _, _, row_x, row_y, row_width = GuiGetPreviousWidgetInfo(gui)
	GuiLayoutEnd(gui)

	local label_width, label_height = GuiGetTextDimensions(gui, GameTextGet("$menugameover_newgame"), 1)
	tracker.new_game_hovered = probe_box(gui, NEW_GAME_PROBE_ID, row_x + row_width / 2 - label_width / 2, row_y, label_width, label_height)
end

---Draws the hover probes for the current screen.
---@param gui gui
---@param screen_width number
---@param screen_height number
function tracker.draw(gui, screen_width, screen_height)
	tracker.new_game_hovered = false
	tracker.return_hovered = false
	if not lost_run_screen_up() or tracker.progress_open then return end
	if tracker.screen == "game_over" then
		probe_game_over(gui, screen_width, screen_height)
	elseif tracker.screen == "new_game" and not tracker.submenu_nested then
		local label_width, label_height = GuiGetTextDimensions(gui, GameTextGet("$menu_return"), 1)
		tracker.return_hovered = probe_box(gui, RETURN_PROBE_ID, screen_width * 0.04, screen_height * 0.93, label_width, label_height)
	end
end

---Returns the on-screen midpoint of the game-over title's right edge, as of the last draw.
---@return number right
---@return number middle
function tracker.logo_right_middle()
	return tracker.logo_right, tracker.logo_middle
end

---Returns whether the death screen itself is showing, so the death splash should be too.
---@return boolean
function tracker.should_show_splash()
	return lost_run_screen_up() and tracker.screen == "game_over" and not tracker.progress_open
end

---Follows clicks from the death screen to New Game and back.
---@param left_click boolean
local function update_screen(left_click)
	local accept = InputIsKeyJustDown(KEY_RETURN) or InputIsKeyJustDown(KEY_KP_ENTER) or InputIsJoystickButtonJustDown(0, JOY_A)
	local back = InputIsKeyJustDown(KEY_ESCAPE) or InputIsJoystickButtonJustDown(0, JOY_START)
	if tracker.screen == "game_over" then
		-- The buttons only appear after one of these inputs, so the first one cannot be pressing them.
		if left_click and tracker.stats_may_show and tracker.new_game_hovered then
			tracker.screen = "new_game"
			tracker.submenu_nested = false
		end
		if left_click or accept or back or InputIsKeyJustDown(KEY_SPACE) then tracker.stats_may_show = true end
	elseif tracker.screen == "new_game" then
		if back or (left_click and tracker.return_hovered) then
			-- The press may have closed a screen opened on top instead.
			tracker.screen = tracker.submenu_nested and "lost" or "game_over"
		elseif left_click or accept then
			tracker.submenu_nested = true
		end
	end
end

---OnWorldPreUpdate handler; the native buttons act on mouse release later in the same frame.
function tracker.update()
	if not tracker.player_died then return end
	tracker.progress_open = tracker.progress_drawn
	tracker.progress_drawn = false
	if not tracker.progress_open then update_screen(InputIsMouseButtonJustUp(1)) end
end

---OnCountSecrets handler for the Progress screen opened from the death screen.
function tracker.count_secrets()
	tracker.progress_drawn = true
end

---OnPausedChanged handler. Pausing needs an empty screen stack, so the death screen is what is under it.
---@param is_paused boolean
---@param is_inventory_pause boolean
function tracker.pause_changed(is_paused, is_inventory_pause)
	if is_paused and not is_inventory_pause then tracker.screen = "game_over" end
end

---OnPlayerDied handler
function tracker.player_destroyed()
	tracker.player_died = true
end

return tracker
