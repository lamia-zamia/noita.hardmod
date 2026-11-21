local dev_messages = {
	{
		from = "qtyui_",
		message = "Working on this mod was very fun. This is my first time ever working on a mod this large,\nand I'm proud to have written more than 10,000 lines of code for this mod!\nI hope you had fun, player, and congratulations on winning Hard Mod!",
		credit = "https://yui.dev"
	},
	{
		from = "Conga Lyne",
		message = "Thankyou for playing Hardmod and thankyou for playing Noita!\nThis community is a very warm place to be and I'm happy to be part of it!\nI hope my own pursuits can live up to even a tenth of the beauty Noita has within it.",
		credit = "https://congalyne.dev/"
	},
	{
		from = "UserK",
		message = "This project took up way too much of my time, genuinely egregious.\nHere's to it taking even more in the future!",
		credit = "UserK"
	},
	{
		from = "Copi",
		message = "This project took up way too little of my time, barely egregious.\nThe others deserve all the recognition they can get for their hard work,\ncheers to another community collab & a rushed workshop image.",
		credit = "Copi"
	},
	{
		from = "Dani2D",
		message = "Working on Harmod with my lovely colleagues at Notla Games\nhas been one of the best unpaid full-time jobs I'll ever have.\nI hope playing it has brought you as much joy and frustration\nas it brought us while making it.\nThank you for playing!",
		credit = "https://meyer.games/"
	},
	{
		from = "Evaisa",
		message = "Hiii I am to blame for making this happen again.\nThis time I had not a lot of motivation to actually add stuff though.\nAnyway die die die die die die die die die snail die die die die die\ndie die die die die die die die die die die\ndie die die solve my riddle.",
		credit = "https://evaisa.dev/"
	},
	{
		from = "Lamia",
		message = "Lamia asked me to write 'im tired' for them, all praise Lamia \\o/",
		credit = "Zamia",
	},
}

local SPECIAL_THANKS = [[



Special thanks to Spoopy and CxRedix, for their visual
designs of the cosmetic Hardmod completion rewards!

Special thanks to GDLiZy, princeoflight612, realloh and
others in the Noita community for their extensive playtesting
and honest feedback throughout the development process!

Special thanks to YOU, for voluntarily suffering through the
twists and turns of our (ever so slightly evil) collab project!





]]
local FINAL_WORDS = [[
 
 
 
 
 
===========
FINAL WORDS
===========
 
Find the hidden ARG!
 
 
 
]]
local COMMIT_HISTORY = [[
 




==============
COMMIT HISTORY
==============
 
 
 
]]

local credits = ModTextFileGetContent("mods/noita.hardmod/files/credits.txt")
local commit_log = ModTextFileGetContent("mods/noita.hardmod/files/modules/credits/commit_log.txt")

local modules = dofile_once("mods/noita.hardmod/modules.lua")---@type module_list

local disabled_modules = {}
for _,module in pairs(modules.list) do
	if ModSettingGet("noita.hardmod."..module..".disabled") then
		table.insert(disabled_modules, module)
	end
end

if #disabled_modules > 0 then
	credits = credits .. "\n \nDisabled modules:\n- " .. table.concat(disabled_modules, "\n- ") .. "\n \nTry again with these modules enabled? :)\n \n \n"
end

if #dev_messages > 0 then
	credits = credits .. FINAL_WORDS
	for _,msg in pairs(dev_messages) do
		credits = credits.." \n \n \n \n \nMESSAGE FROM "..msg.from.."\n~"..msg.message.."~\n(c) "..msg.credit.."\n \n \n \n \n \n \n"
	end
end

credits = credits .. SPECIAL_THANKS .. "\n \n \n \n \n" .. COMMIT_HISTORY .. commit_log

local function escape(str) return str:gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1") end
local function add_release_break(target, release)
	target = "\n" .. target .. "\n"
	credits = credits:gsub(escape(target), target .. " \n--- " .. release .. " ---\n \n")
end

--i personally pick the final commit made before a major release
--so everything up to `fixed init` is part of the main development, and `Labor of Loathing is here :)` is up until LOL's release
add_release_break("MATH.MAX, NOT MATH.MIN AAAAAAAAAA", " MAIN RELEASE 9/11/26")

credits = credits .. "\n \n \n \nAdded approximately 95,236,821,904,984 hämisket\n \n \n"

ModTextFileSetContent("data/credits.txt", credits)

return {}
