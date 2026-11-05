---@diagnostic disable: undefined-global
dofile("data/scripts/lib/mod_settings.lua")

--[[
	
	To set your module's icon, create a 16x16 sprite and save it as
	`module_icon_016.png` in the root of your module folder.

	You must run `scripts/build.js` to update the font!!!

	You can put custom icons into `files/fonts/icons` if you need them for custom GUI.
	You can use them like this:

		GuiText(gui, x, y, get_icon("your_icon"), 1, font_icons)
		GuiButton(gui, id, x, y, get_icon("your_icon"), 1, font_icons)
		
	`your_icon` is the icon's filename with .png omitted

]]--


-- (Dani: ordering this list from (roughly) most to least impactful for the average run.)
local module_data = {
	{
		id = "nerfed_combat_healing",
		name = {
			en = "Nerfed Combat Healing",
		},
		desc = {
			en = "Taking damage can give you the Wounded effect, which prevents healing spells and perks.",
		},
	},
	{
		id = "enemy_perks",
		name = {
			en = "Enemy Perks",
		},
		desc = {
			en = "Some enemies now spawn with enemy-unique perks!\n(Note, they have a different pool of perks, there are no Glass Cannon enemies!!)",
		},
	},
	{
		id = "trappier_traps",
		name = {
			en = "Trappier Traps",
		},
		desc = {
			en = "Makes traps more dangerous.",
		},
	},
	{
		id = "cheeseless_triggers",
		name = {
			en = "Cheeseless Triggers",
		},
		desc = {
			en = "The cast delay & spread of spells is now also applied when they are part of a trigger payload.\n(Note: best enabled together with 'Vanilla Spell Rebalances' and 'Rapidfire Nerfs')",
		},
	},
	{
		id = "starter_wands",
		name = {
			en = "Buff Starter Wands",
		},
		desc = {
			en = "What it says on the tin.",
		},
	},
	{
		id = "unshuffle",
		name = {
			en = "Unshuffle"
		},
		desc = {
			en = "Removes Shuffle as a mechanic from the game."
		},
	},
	{
		id = "vanilla_perk_rebalances",
		name = {
			en = "Vanilla Perk Rebalances"
		},
		desc = {
			en = "Rebalances, reworks, removes and replaces some vanilla perks."
		},
	},
	{
		id = "vanilla_spell_rebalances",
		name = {
			en = "Vanilla Spell Rebalances"
		},
		desc = {
			en = "Rebalances, reworks, removes and replaces some vanilla spells.\nIntegral to the progression."
		},
	},
	{
		id = "spells_reweighted",
		name = {
			en = "Spells Reweighted",
		},
		desc = {
			en = "Changes vanilla spell spawn chances, where they spawn, and their mana consumption\nIntegral to the progression.",
		}
	},
	{
		id = "limited_spells",
		name = {
			en = "Limited Spells",
		},
		desc = {
			en = "Changes vanilla spell usecounts, greek letters and related",
		}
	},
	{
		id = "vanilla_quests",
		name = {
			en = "Vanilla Quest Reworks"
		},
		desc = {
			en = "Important changes & rebalances to vanilla quests"
		},
	},
	{
		id = "vanilla_bosses",
		name = {
			en = "Vanilla Boss Reworks"
		},
		desc = {
			en = "Important changes & rebalances to vanilla bosses"
		},
	},
	{
		id = "less_explosive",
		name = {
			en = "Less Explosive Barrels"
		},
		desc = {
			en = "Barrels spawn a flood of material, rather than exploding."
		},
	},
	{
		id = "holy_mountain_rework",
		name = {
			en = "Holy Mountain Rework"
		},
		desc = {
			en = "Reworks the Holy Mountain collapse mechanic."
		},
	},
	{
		id = "holy_mountain_items",
		name = {
			en = "Holy Mountain Items"
		},
		desc = {
			en = "Makes healing and spell refresh in Holy Mountains paid"
		},
	},
	{
		id = "ring_of_returning",
		name = {
			en = "Ring of Returning"
		},
		desc = {
			en = "Each Holy Mountain spawns a breakable item that lets you warp back to them."
		},
	},
	{
		id = "no_more_max_hp_cheesing",
		name = {
			en = "No More Max HP Cheesing"
		},
		desc = {
			en = "It had to go, sorry."
		},
	},
	{
		id = "phantom_nemesis",
		name = {
			en = "Phantom Nemesis"
		},
		desc = {
			en = "A powerful phantom haunts you throughout your run, possessing enemies and giving them buffs that adapt to your strengths."
		},
	},
	{
		id = "alt_fire_anything",
		name = {
			en = "Alt Fire Anything"
		},
		desc = {
			en = "Utility spell that lets you have 8 wand slots. Kinda."
		},
	},
	{
		id = "ending",
		name = {
			en = "Victory"
		},
		desc = {
			en = "Changes the final boss of the game, and adds a cosmetic that you get for winning.\nNote: the cosmetic is only given if you have all modules integral to the progression enabled"
		},
	},
	{
		id = "nerf_vanilla_cheeses",
		name = {
			en = "Nerf Vanilla Cheeses",
		},
		desc = {
			en = "Can't let ya have too much cheese, sorry.",
		},
	},
	{
		id = "chest_tweaks",
		name = {
			en = "Chest Tweaks"
		},
		desc = {
			en = "Changes chest loot and adds two chest-related perks"
		},
	},
	{
		id = "better_anvil",
		name = {
			en = "Better Hiisi Anvil"
		},
		desc = {
			en = "Makes repaired broken wands better, and lets you find & repair broken spells2,\nat the cost of randomizing the anvil's location."
		},
	},
	{
		-- TODO: merge to vanilla spell rebalances?
		id = "rapidfire_nerfs",
		name = {
			en = "Rapidfire Nerfs"
		},
		desc = {
			en = "Changes to Chainsaw and Add Mana; also adds more alternative spells",
		}
	},
	{
		-- TODO: merge to vanilla perk rebalances?
		id = "trial_perks",
		name = {
			en = "Trial Perks"
		},
		desc = {
			en = "A set of perks that reward you for challenging yourself."
		},
	},
	{
		id = "biome_map",
		name = {
			en = "Biome Map Changes"
		},
		desc = {
			en = "Changes the entire world layout, and adds some custom things.\nIntegral to the progression"
		},
	},
	{
		id = "biome_modifiers",
		name = {
			en = "Biome Modifiers+"
		},
		desc = {
			en = "Reworks the biome modifier system"
		},
	},
	{
		id = "stronger_enemies",
		name = {
			en = "Enemy Rebalances"
		},
		desc = {
			en = "Changes what enemies spawn where, rebalances existing enemies and adds custom ones.\nIntegral to the progression."
		},
	},
	{
		id = "potions",
		name = {
			en = "Potion Rebalances"
		},
		desc = {
			en = "Makes the alchemist's flasks actually larger, and changes what potions can generate on pedestals"
		},
	},
	{
		id = "alternate_biomes",
		name = {
			en = "Alt. Biomes"
		},
		desc = {
			en = "Adds some alternative variants to existing biomes"
		},
	},
	{
		id = "polymorph_gui",
		name = {
			en = "Polymorph GUI"
		},
		desc = {
			en = "Baa"
		},
	},
	{
		id = "vanilla_bugfixes",
		name = {
			en = "Vanilla Bugfixes"
		},
		desc = {
			en = "Some vanilla bugfixes"
		},
	},
}

local lang_keys = {
	["English"] = "en",
	["русский"] = "ru",
	["Português (Brasil)"] = "ptbr",
	["Español"] = "eses",
	["Deutsch"] = "de",
	["Français"] = "frfr", -- for real for real
	["Italiano"] = "it",
	["Polska"] = "pl",
	["简体中文"] = "zhcn",
	["日本語"] = "jp",
	["한국어"] = "ko",
	["Українська"] = "ukr",
	["Türkçe"] = "trtr",
}
local current_language = lang_keys[GameTextGetTranslatedOrNot("$current_language")] or "en"

for _,module in ipairs(module_data) do
	module.ui_name = module.name[current_language] and module.name[current_language] or module.name.en or "Unknown"
	module.ui_desc = module.desc[current_language] and module.desc[current_language] or module.desc.en or ""
end


---Auto generated by `scripts/build.js`, do not edit or format
local _icon_chars = {blank="A",default_module_icon="B",disabled="C",alt_fire_anything="D",cheeseless_triggers="E",enemy_perks="F",holy_mountain_rework="G",less_explosive="H",nerfed_combat_healing="I",no_more_max_hp_cheesing="J",phantom_nemesis="K",polymorph_gui="L",rapidfire_nerfs="M",ring_of_returning="N",starter_wands="O",trappier_traps="P",trial_perks="Q",unshuffle="R",vanilla_perk_rebalances="S",vanilla_spell_rebalances="T"}

---Use this to get an icon instead of accessing _icon_chars directly
---@param icon string Name of the icon from _icon_chars
---@param default string? Default value
local function get_icon(icon, default)
	return _icon_chars[icon] or _icon_chars[default] or _icon_chars.blank or "A"
end

--Key binding data
local listening_alt_fire = false
local there_has_been_input = false
local old_binding = 0
local current_keybind = ""
--Key binding strings
local keybind_name = "Keybind"
local keybind_desc_altfire = "Edit your Alt Fire keybind"
local keybind_tutorial_altfire = "\nHit the prompt below to input a new alt-fire binding.\nThe default setting is the right mouse button."
local keybind_newbinding = "SET NEW BINDING"
local keybind_current = "Current binding: "

local mouse_codes = {
	Mouse_left = 1,
	Mouse_right = 2,
	Mouse_middle = 3,
	Mouse_wheel_up = 4,
	Mouse_wheel_down = 5,
	Mouse_x1 = 6,
	Mouse_x2 = 7,
}

local key_codes = {
	Key_a = 4,
	Key_b = 5,
	Key_c = 6,
	Key_d = 7,
	Key_e = 8,
	Key_f = 9,
	Key_g = 10,
	Key_h = 11,
	Key_i = 12,
	Key_j = 13,
	Key_k = 14,
	Key_l = 15,
	Key_m = 16,
	Key_n = 17,
	Key_o = 18,
	Key_p = 19,
	Key_q = 20,
	Key_r = 21,
	Key_s = 22,
	Key_t = 23,
	Key_u = 24,
	Key_v = 25,
	Key_w = 26,
	Key_x = 27,
	Key_y = 28,
	Key_z = 29,
	Key_1 = 30,
	Key_2 = 31,
	Key_3 = 32,
	Key_4 = 33,
	Key_5 = 34,
	Key_6 = 35,
	Key_7 = 36,
	Key_8 = 37,
	Key_9 = 38,
	Key_0 = 39,
	Key_RETURN = 40,
	Key_ESCAPE = 41,
	Key_BACKSPACE = 42,
	Key_TAB = 43,
	Key_SPACE = 44,
	Key_MINUS = 45,
	Key_EQUALS = 46,
	Key_LEFTBRACKET = 47,
	Key_RIGHTBRACKET = 48,
	Key_BACKSLASH = 49,
	Key_NONUSHASH = 50,
	Key_SEMICOLON = 51,
	Key_APOSTROPHE = 52,
	Key_GRAVE = 53,
	Key_COMMA = 54,
	Key_PERIOD = 55,
	Key_SLASH = 56,
	Key_CAPSLOCK = 57,
	Key_F1 = 58,
	Key_F2 = 59,
	Key_F3 = 60,
	Key_F4 = 61,
	Key_F5 = 62,
	Key_F6 = 63,
	Key_F7 = 64,
	Key_F8 = 65,
	Key_F9 = 66,
	Key_F10 = 67,
	Key_F11 = 68,
	Key_F12 = 69,
	Key_PRINTSCREEN = 70,
	Key_SCROLLLOCK = 71,
	Key_PAUSE = 72,
	Key_INSERT = 73,
	Key_HOME = 74,
	Key_PAGEUP = 75,
	Key_DELETE = 76,
	Key_END = 77,
	Key_PAGEDOWN = 78,
	Key_RIGHT = 79,
	Key_LEFT = 80,
	Key_DOWN = 81,
	Key_UP = 82,
	Key_NUMLOCKCLEAR = 83,
	Key_KP_DIVIDE = 84,
	Key_KP_MULTIPLY = 85,
	Key_KP_MINUS = 86,
	Key_KP_PLUS = 87,
	Key_KP_ENTER = 88,
	Key_KP_1 = 89,
	Key_KP_2 = 90,
	Key_KP_3 = 91,
	Key_KP_4 = 92,
	Key_KP_5 = 93,
	Key_KP_6 = 94,
	Key_KP_7 = 95,
	Key_KP_8 = 96,
	Key_KP_9 = 97,
	Key_KP_0 = 98,
	Key_KP_PERIOD = 99,
	Key_NONUSBACKSLASH = 100,
	Key_APPLICATION = 101,
	Key_POWER = 102,
	Key_KP_EQUALS = 103,
	Key_F13 = 104,
	Key_F14 = 105,
	Key_F15 = 106,
	Key_F16 = 107,
	Key_F17 = 108,
	Key_F18 = 109,
	Key_F19 = 110,
	Key_F20 = 111,
	Key_F21 = 112,
	Key_F22 = 113,
	Key_F23 = 114,
	Key_F24 = 115,
	Key_EXECUTE = 116,
	Key_HELP = 117,
	Key_MENU = 118,
	Key_SELECT = 119,
	Key_STOP = 120,
	Key_AGAIN = 121,
	Key_UNDO = 122,
	Key_CUT = 123,
	Key_COPY = 124,
	Key_PASTE = 125,
	Key_FIND = 126,
	Key_MUTE = 127,
	Key_VOLUMEUP = 128,
	Key_VOLUMEDOWN = 129,
	Key_KP_COMMA = 133,
	Key_KP_EQUALSAS400 = 134,
	Key_INTERNATIONAL1 = 135,
	Key_INTERNATIONAL2 = 136,
	Key_INTERNATIONAL3 = 137,
	Key_INTERNATIONAL4 = 138,
	Key_INTERNATIONAL5 = 139,
	Key_INTERNATIONAL6 = 140,
	Key_INTERNATIONAL7 = 141,
	Key_INTERNATIONAL8 = 142,
	Key_INTERNATIONAL9 = 143,
	Key_LANG1 = 144,
	Key_LANG2 = 145,
	Key_LANG3 = 146,
	Key_LANG4 = 147,
	Key_LANG5 = 148,
	Key_LANG6 = 149,
	Key_LANG7 = 150,
	Key_LANG8 = 151,
	Key_LANG9 = 152,
	Key_ALTERASE = 153,
	Key_SYSREQ = 154,
	Key_CANCEL = 155,
	Key_CLEAR = 156,
	Key_PRIOR = 157,
	Key_RETURN2 = 158,
	Key_SEPARATOR = 159,
	Key_OUT = 160,
	Key_OPER = 161,
	Key_CLEARAGAIN = 162,
	Key_CRSEL = 163,
	Key_EXSEL = 164,
	Key_KP_00 = 176,
	Key_KP_000 = 177,
	Key_THOUSANDSSEPARATOR = 178,
	Key_DECIMALSEPARATOR = 179,
	Key_CURRENCYUNIT = 180,
	Key_CURRENCYSUBUNIT = 181,
	Key_KP_LEFTPAREN = 182,
	Key_KP_RIGHTPAREN = 183,
	Key_KP_LEFTBRACE = 184,
	Key_KP_RIGHTBRACE = 185,
	Key_KP_TAB = 186,
	Key_KP_BACKSPACE = 187,
	Key_KP_A = 188,
	Key_KP_B = 189,
	Key_KP_C = 190,
	Key_KP_D = 191,
	Key_KP_E = 192,
	Key_KP_F = 193,
	Key_KP_XOR = 194,
	Key_KP_POWER = 195,
	Key_KP_PERCENT = 196,
	Key_KP_LESS = 197,
	Key_KP_GREATER = 198,
	Key_KP_AMPERSAND = 199,
	Key_KP_DBLAMPERSAND = 200,
	Key_KP_VERTICALBAR = 201,
	Key_KP_DBLVERTICALBAR = 202,
	Key_KP_COLON = 203,
	Key_KP_HASH = 204,
	Key_KP_SPACE = 205,
	Key_KP_AT = 206,
	Key_KP_EXCLAM = 207,
	Key_KP_MEMSTORE = 208,
	Key_KP_MEMRECALL = 209,
	Key_KP_MEMCLEAR = 210,
	Key_KP_MEMADD = 211,
	Key_KP_MEMSUBTRACT = 212,
	Key_KP_MEMMULTIPLY = 213,
	Key_KP_MEMDIVIDE = 214,
	Key_KP_PLUSMINUS = 215,
	Key_KP_CLEAR = 216,
	Key_KP_CLEARENTRY = 217,
	Key_KP_BINARY = 218,
	Key_KP_OCTAL = 219,
	Key_KP_DECIMAL = 220,
	Key_KP_HEXADECIMAL = 221,
	Key_LCTRL = 224,
	Key_LSHIFT = 225,
	Key_LALT = 226,
	Key_LGUI = 227,
	Key_RCTRL = 228,
	Key_RSHIFT = 229,
	Key_RALT = 230,
	Key_RGUI = 231,
	Key_MODE = 257,
	Key_AUDIONEXT = 258,
	Key_AUDIOPREV = 259,
	Key_AUDIOSTOP = 260,
	Key_AUDIOPLAY = 261,
	Key_AUDIOMUTE = 262,
	Key_MEDIASELECT = 263,
	Key_WWW = 264,
	Key_MAIL = 265,
	Key_CALCULATOR = 266,
	Key_COMPUTER = 267,
	Key_AC_SEARCH = 268,
	Key_AC_HOME = 269,
	Key_AC_BACK = 270,
	Key_AC_FORWARD = 271,
	Key_AC_STOP = 272,
	Key_AC_REFRESH = 273,
	Key_AC_BOOKMARKS = 274,
	Key_BRIGHTNESSDOWN = 275,
	Key_BRIGHTNESSUP = 276,
	Key_DISPLAYSWITCH = 277,
	Key_KBDILLUMTOGGLE = 278,
	Key_KBDILLUMDOWN = 279,
	Key_KBDILLUMUP = 280,
	Key_EJECT = 281,
	Key_SLEEP = 282,
	Key_APP1 = 283,
	Key_APP2 = 284,
	Key_SPECIAL_COUNT = 512,
}

local joystick_codes = {
	JOY_BUTTON_DPAD_UP = 11,
	JOY_BUTTON_DPAD_DOWN = 12,
	JOY_BUTTON_DPAD_LEFT = 13,
	JOY_BUTTON_DPAD_RIGHT = 14,
	JOY_BUTTON_START = 15,
	JOY_BUTTON_BACK = 16,
	JOY_BUTTON_LEFT_THUMB = 17,
	JOY_BUTTON_RIGHT_THUMB = 18,
	JOY_BUTTON_LEFT_SHOULDER = 19,
	JOY_BUTTON_RIGHT_SHOULDER = 20,
	JOY_BUTTON_0 = 23,
	JOY_BUTTON_1 = 24,
	JOY_BUTTON_2 = 25,
	JOY_BUTTON_3 = 26,
	JOY_BUTTON_4 = 27,
	JOY_BUTTON_5 = 28,
	JOY_BUTTON_6 = 29,
	JOY_BUTTON_7 = 30,
	JOY_BUTTON_8 = 31,
	JOY_BUTTON_9 = 32,
	JOY_BUTTON_10 = 33,
	JOY_BUTTON_11 = 34,
	JOY_BUTTON_12 = 35,
	JOY_BUTTON_13 = 36,
	JOY_BUTTON_14 = 37,
	JOY_BUTTON_15 = 38,
	JOY_BUTTON_LEFT_STICK_LEFT = 39,
	JOY_BUTTON_LEFT_STICK_RIGHT = 40,
	JOY_BUTTON_LEFT_STICK_UP = 41,
	JOY_BUTTON_LEFT_STICK_DOWN = 42,
	JOY_BUTTON_RIGHT_STICK_LEFT = 43,
	JOY_BUTTON_RIGHT_STICK_RIGHT = 44,
	JOY_BUTTON_RIGHT_STICK_UP = 45,
	JOY_BUTTON_RIGHT_STICK_DOWN = 46,
	JOY_BUTTON_A = 23,
	JOY_BUTTON_B = 24,
	JOY_BUTTON_X = 25,
	JOY_BUTTON_Y = 26,
}

local thumbstick_codes = {
	gamepad_left_stick = 0,
	gamepad_right_stick = 1,
}

local trigger_codes = {
	gamepad_left_trigger = 0,
	gamepad_right_trigger = 1,
}

local font_dir
if ModDoesFileExist("mods/noita.hardmod/files/fonts/module_icons.xml") then
	font_dir = "mods/noita.hardmod/files/fonts/"
else
	---Auto generated by `scripts/build.js`, do not edit or format
	local _workshop_id = "0"
	font_dir = "../../workshop/content/881100/".._workshop_id.."/files/fonts/workshop/"
end
local font_icons = font_dir.."module_icons.xml"

function has_value (table, value)
  for _, v in ipairs(table) do
	  if v == value then
		  return true
	  end
  end
  return false
end

function input_listen(key_inputs,mouse_inputs,joystick_inputs,mod_setting)
	local there_is_input = false
	for _, code in pairs(key_codes) do
		if InputIsKeyDown(code) then
			there_is_input = true
			there_has_been_input = true
			if has_value(key_inputs, code) == false then
				table.insert(key_inputs, code)
			end
		end
	end
	for _, code in pairs(mouse_codes) do
		if InputIsMouseButtonDown(code) then
			there_is_input = true
			there_has_been_input = true
			if has_value(mouse_inputs, code) == false then
				table.insert(mouse_inputs, code)
			end
		end
	end
	for _, code in pairs(joystick_codes) do
		if InputIsJoystickButtonDown(0, code) then
			there_is_input = true
			there_has_been_input = true
			if has_value(joystick_inputs, code) == false then
				table.insert(joystick_inputs, code)
			end
		end
	end

	--Decided variable forces only a single keybind for input and blocks combo inputs, can be remove to disable this limiter
	local decided = false
	local binding = "key_code,"
	for _, code in pairs(key_inputs) do
		if decided == true then break end
		binding = table.concat({binding,tostring(code),","})
		decided = true
	end
	binding = binding .. "mouse_code,"
	for _, code in pairs(mouse_inputs) do
		if decided == true then break end
		binding = table.concat({binding,tostring(code),","})
		decided = true
	end
	binding = binding .. "joystick_code,"
	for _, code in pairs(joystick_inputs) do
		if decided == true then break end
		binding = table.concat({binding,tostring(code),","})
		decided = true
	end
	binding = binding:sub(1, -2)
	ModSettingSet( mod_setting, binding )

	if there_has_been_input and not there_is_input then
		listening_alt_fire = false
		listening_mid_fire = false
		listening_beacon = false
		there_has_been_input = false
		key_inputs = {}
		mouse_inputs = {}
		joystick_inputs = {}
		if ModSettingGet( mod_setting ) == "key_code,mouse_code,joystick_code" then
		  ModSettingSet( mod_setting, old_binding )
		end
	end
end

local mod_id = "noita.hardmod" -- This should match the name of your mod's folder.
mod_settings_version = 1 -- This is a magic global that can be used to migrate settings to new mod versions. call mod_settings_get_version() before mod_settings_update() to get the old value.
mod_settings =
{
	{
		category_id = "alt_fire_settings",
		ui_name = "Alt Fire Anything",
		ui_description = "Which button should be used to cast Alt Fire Anything?",
		foldable = true,
		_folded = true,
		settings = {
			{
				id = "alt_fire_keybind",
				ui_name = "Keybind",
				value_default = "key_code,mouse_code,2,joystick_code",
				ui_fn = function(mod_id, gui, in_main_menu, im_id, setting)
							local inputs = dofile_once("mods/noita.hardmod/lib/inputs_lists.lua")

							if listening_alt_fire then
								input_listen(key_inputs,mouse_inputs,joystick_inputs,"noita.hardmod.alt_fire_keybind")
							end

							local _id = 0
							local function id()
							  _id = _id + 1
							  return _id
							end

							local keybind_string = ""
							local keybind_setting = ModSettingGet("noita.hardmod.alt_fire_keybind")
							local mode = "key_code"
							for code in string.gmatch(keybind_setting, "[^,]+") do
							  if code == "mouse_code" or code == "key_code" or code == "joystick_code" then
								  mode = code
							  else
								  if keybind_string ~= "" then
									  keybind_string = keybind_string .. " + "
								  end
								  code = tonumber(code)
								  if mode == "key_code" then
									  for key, value in pairs(key_codes) do
										  if value == code then
											  keybind_string = keybind_string .. key
											  ModSettingSet("noita.hardmod.alt_fire_keybind_translated",key)
										  end
									  end
								  elseif mode == "mouse_code" then
									  for key, value in pairs(mouse_codes) do
										  if value == code then
											  keybind_string = keybind_string .. key
											  ModSettingSet("noita.hardmod.alt_fire_keybind_translated",key)
										  end
									  end
								  elseif mode == "joystick_code" then
									  for key, value in pairs(joystick_codes) do
										  if value == code then
											  keybind_string = keybind_string .. key
											  ModSettingSet("noita.hardmod.alt_fire_keybind_translated",key)
										  end
									  end
								  end
							  end
							end

							GuiColorSetForNextWidget(gui, 1, 1, 1, 0.5)
							GuiText(gui, 5, 0, keybind_tutorial_altfire)
							if listening_alt_fire then
							  GuiColorSetForNextWidget(gui, 1, 0, 0, 1)
							  GuiOptionsAdd(gui, GUI_OPTION.NonInteractive)
							end
							if GuiButton(gui, id(), 10, 5, keybind_newbinding) then
							  key_inputs = {}
							  mouse_inputs = {}
							  joystick_inputs = {}
							  listening_alt_fire = true
							  listening_mid_fire = false
							  listening_beacon = false
							  there_has_been_input = false
							  old_binding = ModSettingGet("noita.hardmod.alt_fire_keybind")
							end
							GuiColorSetForNextWidget(gui, 1, 1, 1, 0.5)
							GuiText(gui, 5, 5, keybind_current .. keybind_string)
							GuiText(gui, 0, -5, " ")
							end
			},
			{
				id = "alt_fire_keybind_translated",
				ui_name = "Secret setting",
				value_default = "MOUSE_RIGHT",
				text_max_length = 20,
				allowed_characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789",
				hidden = true,
			},
			{
				id = "alt_fire_enable_in_inventory",
				ui_name = "Enable Alt Fire Anything while inventory is open",
				ui_description = "When enabled, Alt Fire Anything will also function\nwhen the inventory is opened.",
				value_default = false,
				scope = MOD_SETTING_SCOPE_RUNTIME,
			},
		},
	},
}

local function patch_games_init_lua()
	local file = "data/scripts/init.lua"
	ModLuaFileAppend(file, "mods/noita.hardmod/files/modules/biome_modifiers/init_patcher.lua")
end

function ModSettingsUpdate(init_scope)
	local old_version = mod_settings_get_version(mod_id)
	mod_settings_update(mod_id, mod_settings, init_scope)

	if init_scope == 0 or init_scope == 1 then patch_games_init_lua() end
end

function ModSettingsGuiCount()
	return mod_settings_gui_count(mod_id, mod_settings)
end

function HasSettingFlag(name)
	return ModSettingGet(name) or false
end

function AddSettingFlag(name)
	ModSettingSet(name, true)
  --  ModSettingSetNextValue(name, true)
end

function RemoveSettingFlag(name)
	ModSettingRemove(name)
end

function ModSettingsGui( gui, in_main_menu )
	screen_width, screen_height = GuiGetScreenDimensions(gui)

	local id = 46323
	local function new_id() id = id + 1; return id end

	GuiOptionsAdd( gui, GUI_OPTION.NoPositionTween )

	local modules = {}
	for i,module in ipairs( module_data ) do
		if module.force_enable_state == nil then
			table.insert( modules, module )
		end
	end

	GuiLayoutBeginHorizontal( gui, 0, 0, false, 12, 8 )
	GuiColorSetForNextWidget( gui, 0.5, 0.5, 0.5, 1 )
	GuiText( gui, 0, 3, "Toggle modules" )
	GuiLayoutEnd( gui )

	GuiColorSetForNextWidget( gui, 1, 1, 1, 1 )
	for i,module in ipairs( modules ) do
		local module_disabled = "noita.hardmod."..module.id..".disabled"
		GuiLayoutBeginHorizontal( gui, 0, 0, false, 2, 2 )

		local icon = get_icon(module.id, "default_module_icon")
		GuiText(gui, 4, 0, icon, 1, font_icons)
		GuiText(gui, -18, 0, get_icon("blank"), 1, font_icons)

		if HasSettingFlag( module_disabled ) then
			GuiZSetForNextWidget( gui, -80 )
			-- GuiOptionsAddForNextWidget( gui, GUI_OPTION.NonInteractive )
			GuiText(gui, -18, 0, get_icon("disabled"), 1, font_icons)
			-- GuiImage( gui, new_id(), -20.2, -1.2, "mods/noita.hardmod/lib/ui_sprites/settings_content_disabled_overlay.png", 1, 1.2, 0 )
		end

		if HasSettingFlag( module_disabled ) then
			GuiColorSetForNextWidget( gui, 1, 0.25, 0.25, 1 )
		else
			GuiColorSetForNextWidget( gui, 1, 1, 1, 1 )
		end

		-- im so smart
		local offset = "       "
		local label = GameTextGetTranslatedOrNot(module.ui_name)

		local clicked,right_clicked = GuiButton(gui, new_id(), -18, 3, offset..label)
		if clicked then
			if HasSettingFlag( module_disabled ) then
				RemoveSettingFlag( module_disabled )
			else
				AddSettingFlag( module_disabled )
			end
		end

		local tooltip_text = GameTextGetTranslatedOrNot( module.ui_desc ) .. "\n "
		local tooltip_status = HasSettingFlag(module_disabled) and "[Click to enable]" or "[Click to disable]"
		GuiTooltip(gui, tooltip_text, tooltip_status)

		GuiLayoutEnd( gui )
	end

	GuiOptionsAdd( gui, GUI_OPTION.NoPositionTween )

	GuiColorSetForNextWidget( gui, 1, 1, 1, 1 )
	for i = 1, 5 do
		GuiText( gui, 0, 0, "" )
	end

	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
	-- GuiLayoutEnd(gui)
end
