---@alias splash_font
---| "data/fonts/font_pixel.xml"
---| "data/fonts/font_pixel_noshadow.xml"
---| "data/fonts/font_pixel_white.xml"
---| "data/fonts/font_pixel_big.xml"
---| "data/fonts/font_pixel_huge.xml"
---| "data/fonts/font_small_numbers.xml" # digits and a few letters only
---| "data/fonts/font_damage.xml" # digits and `-` only
---| "data/fonts/font_pixel_runes.xml"
---| string

---One piece of a custom splash: either text or an image.
---@class splash_part
---@field [1] string? text to draw, `\n` starts a new line; leave out when using `image`
---@field image string? PNG path to draw instead of text
---@field color rotatable_text_color? tint; text falls back to the entry's color, images stay untinted
---@field font splash_font? font of this text; falls back to the entry's font
---@field scale number? `1` size multiplier on top of the entry's `scale`

---A splash with custom settings; its parts are drawn left to right.
---@class splash_entry
---@field [integer] string|splash_part
---@field color rotatable_text_color? `yellow` tint of all text
---@field font splash_font? `data/fonts/font_pixel.xml` font of all text
---@field scale number? `1` size multiplier of the whole splash
---@field speed number? `1` pulse and swing speed multiplier; `0` holds it level at its base size
---@field angle number? `math.rad(20)` how far it swings each way, in radians

local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils

local y,m,d = GameGetDateAndTimeUTC()
local evil_level = (y * 31469 + m * 929 + d * 541) % 100 + 1

local months = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" }

local lines_of_code = "21,633"---Updated by `scripts/build.js`, do not edit or format

---@type (splash_entry | string)[]
local splashes = {
	lines_of_code.." Lines Of Code",
	"Evil Level Today: " .. evil_level .. "%",
	"Today is "..months[m].." "..utils.EnglishOrd(d)..", "..y,
	"2K"..(y % 100),
	"(c) Hämis Corp "..(y + 10),
	"Dunk is bald",
	"Now atleast 1% harder!",
	"I hope you like dying!",
	"Eba was here",
	"Insert splash text here",
	"Dani2D was here",
	"Every pixel is stimulated",
	"UserK",
	"Brought to you by Team Fairmod",
	"A Notla Classic!",
	"Now with 100% more false-walls!",
	"Well it's not Fairmod!",
	"We were nice this time!",
	">:)",
	"Welcome to your Doom!",
	"Conga Lyne was here",
	"10,000 witches used to make it to the work, now it's a ghost town",
	"Community Collab Mod 2026!",
	"Betcha can't even make it past Hiisi Base!",
	"Now do an all bosses run!",
	"Recommended by 9 out of 10 dentists!",
	"You won't last 5 minutes",
	"Nightmare Impossible Unwinnable Beyond Hell Edition!",
	"Ira was here",
	"Arduus!",
	"Nuke yourself today to heal to full health!",
	"Call 1800-Kolmisilma for a refund on all defective chainsaws",
	"Every pixel is simulated to kill you",
	"You CAN Win Me; I CAN Be Beat :)",
	"TANNEREYE IS DEAD.",
	"Ira approaches",
	"Ira? More like IRATE!!! gottem",
	"The Divine is on the phone, pick up.",
	"\"Fair mod too\"? I sure hope it is!",
	"Enemies may bleed lava!",
	"Crystals entwined deceive divine!",
	"Note: Some things may be 1% easier",
	"Now with rotation!",
	"Everyone say \"Thank you Lamier\" for making this text rotatable!",
	"Saving Grace had it coming.",
	"Beat this to unlock Epilogue 3!",
	"Lamia was drunk",
	"qtyui_ was here",
	"NT Sadge",
	"Sponsored by CEO Hiisilius IV",
	"No Fun Allowed",
	"0% cheese!",
	"Fair Mod 2: This Time It's Actually Fair",
	"Fixes NB-13, NB-25 and NB-103",
	"No 5wand, sorry!",
	"exploding u :3",
	"noita.harmod",
	"woag...\nnewline...",
	"why do these splashes keep mentioning a \"fair mod\"????",
	"Polymorph Immunity perk!!!! (enemies only)",
	"Made with love, passion, and also a lot of spite!",
	"What do you mean the deadline is nearly up?!?",
	"Now +50% more vegan friendly",
	"Flummoxium stocks on the rise!",
	"\\^-^/",
	"\\m/ d(-_-)b",
	"ok who broke multicast",
}

local cool_mods = {
	"Fairmod",
	"Perkageddon",
	"Apotheosis",
	"D2D Content Pack",
}
for _,coolmod in ipairs(cool_mods) do
	splashes[#splashes+1] = "Also try "..coolmod.."!"
end

-- Splashes with custom settings; a text only needs to be here if it has any. For example:
-- { "Dunk is bald", color = { r = 1, g = 0.2, b = 0.2 }, scale = 1.5, speed = 2, angle = math.rad(45) },
-- { "Evil Level: ", { evil_level .. "%", color = { r = 1, g = 0, b = 0 }, font = "data/fonts/font_pixel_big.xml" } },
-- { "Hämis ", { image = "data/ui_gfx/hud/health.png", scale = 0.5 }, " :+1:" },
---@type splash_entry[]
local custom_splashes = {
	{"Hämis ", { image = "mods/noita.hardmod/files/modules/logo_splash/gfx/thumbsup.png", scale = 0.75, color= {r = 1, g = 1, b = 1} }},
	{
		{"N",color={r=1,g=0.2,b=0.2}},
		{"o",color={r=1,g=0.65,b=0.2}},
		{"w ",color={r=1,g=1,b=0.2}},
		{"w",color={r=0.65,g=1,b=0.2}},
		{"i",color={r=0.2,g=1,b=0.2}},
		{"t",color={r=0.2,g=1,b=0.65}},
		{"h ",color={r=0.2,g=1,b=1}},
		{"c",color={r=0.2,g=0.65,b=1}},
		{"o",color={r=0.2,g=0.2,b=1}},
		{"l",color={r=0.65,g=0.2,b=1}},
		{"o",color={r=1,g=0.2,b=1}},
		{"r",color={r=1,g=0.2,b=0.65}},
		{"!",color={r=1,g=0.2,b=0.2}},
	}
}

for _,splash in pairs(custom_splashes) do
	table.insert(splashes, splash)
end

local win_splashes = {
	"I Won Hard Mod and All I Got Was This Lousy Splash Text",
	"God Gamer?",
	"If you won Hard Mod, surely you can win Fair Mod too!",
	"Impressive!!!",
	"Enjoy your golden starter wands",
	"There's more to explore here",
}

if HasFlagPersistent("hardmod_game_completed") then
	for _,splash in pairs(win_splashes) do table.insert(splashes, splash) end
end

return splashes
