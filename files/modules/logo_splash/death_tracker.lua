---@class death_tracker
---@field player_died boolean OnPlayerDied ran
local tracker = {
	player_died = false,
}

local GUI_OPTION_ALIGN_HORIZONTAL_CENTER = 16

local TITLE_PROBE_ID = 9830
local LAYOUT_MARGIN_X = 4
local LAYOUT_MARGIN_Y = 0
local TITLE_IMAGE = "data/ui_gfx/game_over_menu/game_over.png"
local COMPLETED_IMAGE = "data/ui_gfx/game_over_menu/game_completed.png"
-- Vertical offsets once the title has settled; for its first 0.77 seconds it rises into place from 15 lower.
local TITLE_OFFSET_Y = -3
local COMPLETED_OFFSET_Y = -4

local layout_top_percent = nil ---@type number?

---Returns UI_GAME_OVER_MENU_LAYOUT_TOP_EDGE_PERCENTAGE
---@return number
local function get_layout_top_percent()
	layout_top_percent = layout_top_percent or tonumber(MagicNumbersGetValue("UI_GAME_OVER_MENU_LAYOUT_TOP_EDGE_PERCENTAGE")) or 19
	return layout_top_percent
end

---Returns the on-screen midpoint of the game-over title's right edge
---@param gui gui
---@param screen_width number
---@param screen_height number
---@return number right
---@return number middle
function tracker.logo_right_middle(gui, screen_width, screen_height)
	local completed = GameHasFlagRun("ending_game_completed")
	GuiLayoutBeginVertical(gui, screen_width * 0.5, screen_height * get_layout_top_percent() * 0.01, true, LAYOUT_MARGIN_X, LAYOUT_MARGIN_Y)
	GuiOptionsAddForNextWidget(gui, GUI_OPTION_ALIGN_HORIZONTAL_CENTER)
	GuiImage(gui, TITLE_PROBE_ID, 0, completed and COMPLETED_OFFSET_Y or TITLE_OFFSET_Y, completed and COMPLETED_IMAGE or TITLE_IMAGE, 0, 1, 1, 0, 0, "")
	local _, _, _, x, y, width, height = GuiGetPreviousWidgetInfo(gui)
	GuiLayoutEnd(gui)
	return x + width, y + height / 2
end

---Returns whether the game-over screen is up, so the death splash should be too
---@return boolean
function tracker.should_show_splash()
	return tracker.player_died and not GameHasFlagRun("ending_no_game_over_menu")
end

---OnPlayerDied handler
function tracker.player_destroyed()
	tracker.player_died = true
end

return tracker
