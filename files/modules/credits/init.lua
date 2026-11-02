local dev_messages = {
	{
		from = "qtyui_",
		message = "Working on this mod was very fun. I hope you had fun, player,\nand congratulations on winning Hard Mod!",
		credit = "https://yui.dev"
	}
}

local credits = ModTextFileGetContent("mods/noita.hardmod/files/credits.txt")

if #dev_messages > 0 then
	credits = credits .. "\n \n \n \n \n \n \n===========\nFINAL WORDS\n===========\n \n"
	for _,msg in pairs(dev_messages) do
		credits = credits.."MESSAGE FROM "..msg.from.."\n~"..msg.message.."~\n(c) "..msg.credit.."\n \n"
	end
end

credits = (
	credits
	.. "\n \n=============\nCOMMIT HISTORY\n=============\n \n \n"
	.. ModTextFileGetContent("mods/noita.hardmod/files/modules/credits/commit_log.txt")
)

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
