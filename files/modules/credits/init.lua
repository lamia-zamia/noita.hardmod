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
	}
}

local FINAL_WORDS = [[
 
 
===========
FINAL WORDS
===========
 
 
 
 
 
]]
local COMMIT_HISTORY = [[
 
==============
COMMIT HISTORY
==============
 
 
]]

local credits = ModTextFileGetContent("mods/noita.hardmod/files/credits.txt")
local commit_log = ModTextFileGetContent("mods/noita.hardmod/files/modules/credits/commit_log.txt")

local disabled_modules = {}
for _,module in pairs(HARDMOD_GLOBAL_DATA.module_ids) do
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
		credits = credits.." \n \n \n \n \nMESSAGE FROM "..msg.from.."\n~"..msg.message.."~\n(c) "..msg.credit.."\n \n \n \n \n"
	end
end

credits = credits .. COMMIT_HISTORY .. commit_log

local function escape(str) return str:gsub("[%(%)%.%%%+%-%*%?%[%^%$%]]", "%%%1") end
local function add_release_break(target, release)
	target = "\n" .. target .. "\n"
	credits = credits:gsub(escape(target), target .. " \n--- " .. release .. " ---\n \n")
end

--i personally pick the final commit made before a major release
--so everything up to `fixed init` is part of the main development, and `Labor of Loathing is here :)` is up until LOL's release
--add_release_break("(whatever the last PR is)", " MAIN RELEASE 31/10/26")

credits = credits .. "\n \n \n \nAdded approximately 95,236,821,904,984 hämisket\n \n \n"

ModTextFileSetContent("data/credits.txt", credits)
