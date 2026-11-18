local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
dofile_once("data/scripts/perks/perk.lua")
---@diagnostic disable-next-line: lowercase-global
perk_list = perk_list

local dir = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/"


local x, y = EntityGetTransform( GetUpdatedEntityID() )

local function get_distance( x1, y1, x2, y2 )
	local result = math.sqrt( ( x2 - x1 ) ^ 2 + ( y2 - y1 ) ^ 2 )
	return result
end

local function in_world(eid)
	local comp = EntityGetComponent(eid, "PhysicsBodyComponent")
	return comp and true or false
end

local is_hellmode = GameHasFlagRun("hardmod_hell")

local sacrifice_items = {
	{
		flag = "hardmod_wandstone_sacrificed",
		identity_filename = "data/entities/items/pickup/wandstone.xml",
		spawn_perk = "EDIT_WANDS_EVERYWHERE",
	},
	{
		flag = "hardmod_sacrifice_sunseed",
		identity_tag = "seed_b",
		spawn_perk = "REMOVE_FOG_OF_WAR",
		not_in_hellmode = true,
	},
	{
		flag = "hardmod_sacrifice_thunderstone",
		identity_tag = "thunderstone",
		spawn_perk = "HARDMOD_PROTECTION_ELECTRIC_STUN",
		not_in_hellmode = true,
	},
	{
		flag = "hardmod_sacrifice_brimstone",
		identity_tag = "brimstone",
		spawn_perk = "PROTECTION_FIRE",
		not_in_hellmode = true,
	},
	{
		flag = "hardmod_sacrifice_cheese",
		identity_tag = "hardmod_cheese",
		spawn_perk = "HARDMOD_PROTECTION_FREEZE",
		not_in_hellmode = true,
	},
	{
		flag = "hardmod_sacrifice_cheese",
		identity_tag = "poopstone",
		func = function(eid)
			--flair
			GameScreenshake(80)
			GamePlaySound("data/audio/Desktop/event_cues.bank", "event_cues/orb/create", x, y)
			EntityLoad(dir.."entities/shitass_symbol.xml", x, y)

			--generate perks
			local shit_perks = {}
			for _,perk in ipairs(perk_list) do
				---@diagnostic disable-next-line: undefined-field
				if perk.hardmod_shit_perk then
					shit_perks[#shit_perks+1] = perk.id
				end
			end

			for i = #shit_perks, 2, -1 do
				local j = math.random(i)
				shit_perks[i], shit_perks[j] = shit_perks[j], shit_perks[i]
			end

			SetRandomSeed(x-GameGetFrameNum(), y)
			local spawned_perks = utils.SpawnPerkCircle(shit_perks, x, y, 220)


			--modify perks
			for _,shit_perk in ipairs(spawned_perks) do
				EntityAddComponent2(shit_perk, "LuaComponent", {
					execute_every_n_frame = -1,
					script_item_picked_up = dir.."scripts/shit_perk_pickup.lua",
				})
				EntityAddComponent2(shit_perk, "SpriteComponent", {
					image_file = dir.."gfx/shit_perk_border.png",
					offset_x = 8,
					offset_y = 8,
					z_index = .99,
					--update_transform = true,
					--update_transform_rotation = false,
				})
			end

			EntityKill(eid)
		end
	},
}

local tag_items = {}
local filename_items = {}
local entity_name_items = {}

for i,item in ipairs(sacrifice_items) do
	--dont include hellmode-blocked items if in hellmode
	if is_hellmode and item.not_in_hellmode then goto continue end

	if item.spawn_perk then
		function item.func(eid)
			local ix,iy = EntityGetTransform(eid)
			-- standard mountain altar feedback
			EntityLoad("data/entities/particles/image_emitters/chest_effect.xml", ix, iy)
			GamePrintImportant("$log_altar_magic")

			-- spawn the perk
			perk_spawn(ix, iy - 10, item.spawn_perk, true)

			-- destroy the stone
			EntityKill(eid)
		end
	end
	if item.identity_tag then
		tag_items[#tag_items+1] = item
	elseif item.identity_filename then
		filename_items[item.identity_filename] = item
	elseif item.identity_name then
		entity_name_items[item.identity_name] = item
	end
	::continue::
end

local function handle_sacrifice(sacrifice_data, eid)
	sacrifice_data.func(eid)
	if sacrifice_data.flag then GameAddFlagRun(sacrifice_data.flag) end

	GameAddFlagRun("HARDMOD_SACRIFICE_ALL")
	AddFlagPersistent("HARDMOD_ACHIEVEMENT_SACRIFICE_ITEMS")

	if not is_hellmode then
		dofile_once("data/scripts/perks/perk.lua")
		perk_spawn(x, y - 30, "HARDMOD_ITEM_IMMUNITIES", true)

		EntityLoad("data/entities/particles/image_emitters/magical_symbol.xml", x, y - 30)
		GamePlaySound("data/audio/Desktop/projectiles.snd", "player_projectiles/crumbling_earth/create", x, y)
	end

end

for _,eid in ipairs(EntityGetInRadius(x, y, 64)) do
	--dont include entities in a tree (for optimisation + ignoring items in inventory)
	if eid ~= EntityGetRootEntity(eid) then goto continue end

	local name = EntityGetName(eid)
	local path = EntityGetFilename(eid)
	if entity_name_items[name] then handle_sacrifice(filename_items[name], eid)
	elseif filename_items[path] then handle_sacrifice(filename_items[path], eid)
	else
		for _,item in ipairs(tag_items) do
			if EntityHasTag(eid, item.identity_tag) then handle_sacrifice(item, eid) break end
		end
	end
	::continue::
end

-- tinker stone becomes TWWE
local wandstone = EntityGetInRadiusWithTag( x, y, 128, "hardmod_wandstone" )[1]
if wandstone ~= nil and in_world(wandstone) and not is_hellmode then
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

do return end

-- sun stone becomes ASE
local sunstone = EntityGetInRadiusWithTag( x, y, 128, "seed_b" )[1]
if sunstone ~= nil and in_world(sunstone) and not is_hellmode then
	local sx, sy = EntityGetTransform( sunstone )

	if get_distance(x, y, sx, sy) < 64 then
		-- standard mountain altar feedback
		EntityLoad("data/entities/particles/image_emitters/chest_effect.xml", sx, sy)
		GamePrintImportant("$log_altar_magic")

		-- spawn the perk
		dofile_once("data/scripts/perks/perk.lua")
		perk_spawn(sx, sy - 10, "REMOVE_FOG_OF_WAR", true)

		-- destroy the stone
		EntityKill(sunstone)
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
	AddFlagPersistent("HARDMOD_ACHIEVEMENT_SACRIFICE_ITEMS")

	if not is_hellmode then
		dofile_once("data/scripts/perks/perk.lua")
		perk_spawn(x, y - 30, "HARDMOD_ITEM_IMMUNITIES", true)

		EntityLoad("data/entities/particles/image_emitters/magical_symbol.xml", x, y - 30)
		GamePlaySound("data/audio/Desktop/projectiles.snd", "player_projectiles/crumbling_earth/create", x, y)
	end
end
