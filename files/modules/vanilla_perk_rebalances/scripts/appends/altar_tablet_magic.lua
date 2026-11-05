---@diagnostic disable: undefined-global

local x, y = EntityGetTransform( GetUpdatedEntityID() )

local function get_distance( x1, y1, x2, y2 )
	local result = math.sqrt( ( x2 - x1 ) ^ 2 + ( y2 - y1 ) ^ 2 )
	return result
end

local function in_world(eid)
	local comp = EntityGetComponent(eid, "PhysicsBodyComponent")
	return comp and true or false
end

-- tinker stone becomes TWWE
local wandstone = EntityGetInRadiusWithTag( x, y, 128, "hardmod_wandstone" )[1]
if wandstone ~= nil and in_world(wandstone) then
	local sx, sy = EntityGetTransform( wandstone )

	if get_distance(x, y, sx, sy) < 64 then
		-- standard mountain altar feedback
		EntityLoad("data/entities/particles/image_emitters/chest_effect.xml", sx, sy)
		GamePrintImportant("$log_altar_magic")

		-- spawn the perk
	    dofile_once("data/scripts/perks/perk.lua")
		perk_spawn(sx, sy - 10, "EDIT_WANDS_EVERYWHERE", true)

		-- destroy the stone
		EntityKill(wandstone)
	end
end

-- TODO: This fucking sucks

local sac_thunderstone = GameHasFlagRun("HARDMOD_SACRIFICE_THUNDERSTONE")
local sac_brimstone = GameHasFlagRun("HARDMOD_SACRIFICE_BRIMSTONE")
local sac_cheese = GameHasFlagRun("HARDMOD_SACRIFICE_CHEESE")
local sac_all = GameHasFlagRun("HARDMOD_SACRIFICE_ALL")

local thunderstone = EntityGetInRadiusWithTag(x, y, 128, "thunderstone")[1]
if thunderstone and not sac_thunderstone and in_world(thunderstone) then
	local sx, sy = EntityGetTransform(thunderstone)

	if get_distance(x, y, sx, sy) < 64 then
		EntityLoad("data/entities/particles/image_emitters/chest_effect.xml", sx, sy)
		GamePrintImportant("$log_altar_magic")

		dofile_once("data/scripts/perks/perk.lua")
		perk_spawn(sx, sy - 10, "HARDMOD_PROTECTION_ELECTRIC_STUN", true)

		EntityKill(thunderstone)
		GameAddFlagRun("HARDMOD_SACRIFICE_THUNDERSTONE")
		sac_thunderstone = true
	end
end

local brimstone = EntityGetInRadiusWithTag(x, y, 128, "brimstone")[1]
if brimstone and not sac_brimstone and in_world(brimstone) then
	local sx, sy = EntityGetTransform(brimstone)

	if get_distance(x, y, sx, sy) < 64 then
		EntityLoad("data/entities/particles/image_emitters/chest_effect.xml", sx, sy)
		GamePrintImportant("$log_altar_magic")

		dofile_once("data/scripts/perks/perk.lua")
		perk_spawn(sx, sy - 10, "PROTECTION_FIRE", true)

		EntityKill(brimstone)
		GameAddFlagRun("HARDMOD_SACRIFICE_BRIMSTONE")
		sac_brimstone = true
	end
end

local cheese = EntityGetInRadiusWithTag(x, y, 128, "hardmod_cheese")[1]
if cheese and not sac_cheese and in_world(cheese) then
	local sx, sy = EntityGetTransform(cheese)

	if get_distance(x, y, sx, sy) < 64 then
		EntityLoad("data/entities/particles/image_emitters/chest_effect.xml", sx, sy)
		GamePrintImportant("$log_altar_magic")

		dofile_once("data/scripts/perks/perk.lua")
		perk_spawn(sx, sy - 10, "HARDMOD_PROTECTION_FREEZE", true)

		EntityKill(cheese)
		GameAddFlagRun("HARDMOD_SACRIFICE_CHEESE")
		sac_cheese = true
	end
end

if sac_brimstone and sac_cheese and sac_thunderstone and not sac_all then
	GameAddFlagRun("HARDMOD_SACRIFICE_ALL")
	
	dofile_once("data/scripts/perks/perk.lua")
	perk_spawn(x, y - 30, "HARDMOD_ITEM_IMMUNITIES", true)

	EntityLoad("data/entities/particles/image_emitters/magical_symbol.xml", x, y - 30)
	GamePlaySound("data/audio/Desktop/projectiles.snd", "player_projectiles/crumbling_earth/create", x, y)
end
