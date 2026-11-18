local orbs = {
	{ 8, 1 }, -- squiddy orb
	{ 1, -3 }, -- mountain altar orb
	{ 6, 3 }, -- lava lake orb
	{ -10, 7 }, -- orb in that one temple biome with taikas (I KEEP FORGETTING ITS NAME)
	{ -8, 19 }, -- lukki lair orb
	{ 19, -11 }, -- sky orb (stolen from pyramid)
	{ 18, 4 }, -- sandcave orb
	{ -20, 5 }, -- frozen vault orb
	{ -17, 29 }, -- snowy chasm orb
	{ 20, 31 }, -- wizards den orb
	{ -1, 31 }, -- hell orb
}

local result = {}
for _,orb in pairs(orbs) do
	table.insert(result, table.concat(orb, ","))
end

local str = table.concat(result, " ")
GlobalsSetValue("ORB_MAP_STRING", str)
