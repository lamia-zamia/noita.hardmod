dofile_once("data/scripts/items/drop_money.lua")

function death(...)
	do_money_drop(4, true, ...)
end