local hooks = {}
local _g = HARDMOD_GLOBAL_DATA
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local biome_index = dofile_once("mods/noita.hardmod/lib/biome_index.lua") ---@type biome_path_to_simple_id
local eperk_utils ---@type eperk_utils

local curr_path = "mods/noita.hardmod/files/modules/enemy_perks/"

ModLuaFileAppend("data/scripts/perks/perk_reflect.lua", curr_path.."add_perks_to_progress.lua")


local base_perk_chance = .15


local enemy_perks = {}
local enemy_perks_indexed = {}

local offscreen_leniancy = 16 --how many pixels off-screen can the target be before the window closes automatically
local min_dark = 200 --maximum dark value the target can be in before the windo closes automatically

local gz = 100 --Z position that all the GUI is relative to
local x_offset_from_target = 16 --x offset away from the target's origin
local y_offset_from_target = -20 --y offset away from the target's origin
local edge_padding = 3 --padding in pixels from the left, right and bottom sides of the window
local top_padding = 2 --padding between the top of the window and the name, and the name and perk view
local icon_padding = 1 --padding between perks in the perk view
local max_perks_per_row = 5 --max perks before breaking into a new row
local icon_size = 16 --the xy size of the perk icons

hooks.player_spawned = function()
	for _,perk in ipairs(enemy_perks) do
		RemoveFlagPersistent("perk_picked_enemyperk_"..perk.id:lower())
		GameAddFlagRun("new_perk_picked_enemyperk_"..perk.id:lower())
	end
end and nil --comment `and nil` to run above func

local function update_perk_unlock_states()
	for _,perk in ipairs(enemy_perks) do
		perk.locked = not HasFlagPersistent("perk_picked_enemyperk_"..perk.id:lower())
	end
end

hooks.mod_post_init = function() --run later in case of appends
	enemy_perks = dofile_once(curr_path.."enemy_perks_list.lua")
	eperk_utils = dofile_once(curr_path.."eperk_utilities.lua")(enemy_perks)
	for _,perk in ipairs(enemy_perks) do
		enemy_perks_indexed[perk.id] = perk
	end

	update_perk_unlock_states()
end

hooks.new_eid = function(entity_id)
	if EntityHasTag(entity_id, "enemy") and not EntityHasTag(entity_id, "hardmod_blessed") then
		local is_boss = EntityHasTag(entity_id, "boss")
		local x,y = EntityGetTransform(entity_id)
		local biome = biome_index[DebugBiomeMapGetFilename(x, y)]
		local num = 0


		local biome_data = eperk_utils.biome_levels[biome] or eperk_utils.biome_levels.default_biome_data
		if biome_data.custom_func then
			num = biome_data:custom_func(entity_id, x, y) or num
		end

		local level = (is_boss and 5 or biome_data.level) --if is_boss, override biome level
			+ (tonumber(SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")) or 0) -- + NG+ iteration
			+ (GetParallelWorldPosition(x, y) ~= 0 and 3 or 0) -- +3 if in a PW
		if biome_data.do_recursive_roll ~= false then
			for _=1, level do
				local function plus_one_perk()
					if Random() <= base_perk_chance then
						num = num + 1
						plus_one_perk()
					end
				end
				plus_one_perk()
			end
		end

		if biome_data.range then
			num = num + Random(biome_data.range[1], biome_data.range[2])
		end


		--if not biome_levels[biome] then print(biome) end --use to find biomes not yet assigned levels
		--num = 1
		local data = {
			x = x, y = y,
			biome = biome,
			level = level,
			target_enemy = entity_id,
			player = _g.player,
			player_poly_identity = _g.player_poly_identity,
			is_boss = is_boss,
		}
		eperk_utils.give_enemy_perks(entity_id, num, data)
	end
end



local gui = GuiCreate()

local _id = 0
local function new_id()
	_id = _id + 1
	return _id
end

local virt_x, virt_y, screen_width, screen_height, scale_x, scale_y, cx, cy
local function world_to_screen_coordinates(x, y)
	return (x - cx) / scale_x + screen_width / 2 + 1.5, (y - cy) / scale_y + screen_height / 2
end

local cached_perk_hover_info = {}

local selected_creature = nil
function hooks.post_update(frame)
	if GameHasFlagRun("hardmod_new_enemy_perk_discovered") then
		update_perk_unlock_states()
		GameRemoveFlagRun("hardmod_new_enemy_perk_discovered")
	end


	if InputIsKeyJustDown(tonumber(ModSettingGet("noita.hardmod.enemy_perk_inspect_key")) or 18) then
		local x,y = DEBUG_GetMouseWorld()
		selected_creature = EntityGetClosestWithTag(x, y, "hardmod_blessed")
		local creature_x,creature_y = EntityGetTransform(selected_creature)
		if not creature_x then return end
		if (creature_x-x)^2 + (creature_y-y)^2 > 16^2 then selected_creature = nil end
		print("selected creature: "..tostring(selected_creature))
	end

	---@diagnostic disable-next-line: param-type-mismatch
	if not EntityGetIsAlive(selected_creature or 0) then selected_creature = nil end
	if not (selected_creature and EntityGetIsAlive(selected_creature)) then return end

	local creature_x,creature_y = EntityGetTransform(selected_creature)
	if GameGetFogOfWarBilinear(creature_x, creature_y) > min_dark then selected_creature = nil return end

	GuiStartFrame(gui)
	virt_x = MagicNumbersGetValue("VIRTUAL_RESOLUTION_X")
	virt_y = MagicNumbersGetValue("VIRTUAL_RESOLUTION_Y")
	screen_width, screen_height = GuiGetScreenDimensions(gui)
	scale_x = virt_x / screen_width
	scale_y = virt_y / screen_height
	cx, cy = GameGetCameraPos()


	local vx = creature_x - cx + virt_x / 2
	local vy = creature_y - cy + virt_y / 2
	local gui_x = vx * screen_width / virt_x
	local gui_y = vy * screen_height / virt_y
	if gui_x < (0-offscreen_leniancy) or gui_x > (screen_width+offscreen_leniancy) or gui_y < (0-offscreen_leniancy) or gui_y > (screen_height+offscreen_leniancy) then selected_creature = nil return end


	local enemy_perks_handler
	for _,child in ipairs(EntityGetAllChildren(selected_creature) or {}) do
		if EntityGetName(child) == "hardmod.enemy_perks" then enemy_perks_handler = child break end
	end
	if not enemy_perks_handler then return end

	local enemy_perk_data
	for _,varcomp in ipairs(EntityGetComponent(enemy_perks_handler, "VariableStorageComponent") or {}) do
		if ComponentGetValue2(varcomp, "name") == "enemy_perk_data" then enemy_perk_data = varcomp break end
	end
	if not enemy_perk_data then return end

	local target_perks = {}
	for perk_id in ComponentGetValue2(enemy_perk_data, "value_string"):gmatch("([^,]+)") do
		target_perks[#target_perks+1] = utils.deepcopy(enemy_perks_indexed[perk_id])
	end

	table.sort(target_perks, function(a, b)
		return a.priority > b.priority
	end)

	for _,perk in ipairs(target_perks) do
		if perk.func_inspector then
			perk:func_inspector(target_perks)
		end
	end

	local function render_perk(perk, x, y)
		if perk.locked then GuiColorSetForNextWidget(gui, 0.3, 0.3, 0.3, 1) end
		GuiImage(gui, new_id(), x, y, perk.sprite, 1, 1, 1)
		--[[ this would allow you to hover the perk to see in-game and click it to pin it to your screen
		-- But time is running short, and I would like to get this feature out there first, I lost too much time being ill for a week and a half
		-- Sorry!!
		local prev = {GuiGetPreviousWidgetInfo(gui)}
		if prev[3] then
			local perk_hover_info
			if not cached_perk_hover_info[perk.id] then
				cached_perk_hover_info[perk.id] = {
					icon = perk.sprite,
					name = GameTextGetTranslatedOrNot(perk.name),
					box_size = {
						x = edge_padding*2 + icon_size*2 + top_padding + math.max(GuiGetTextDimensions(gui, perk_hover_info.name), 48),
						y = top_padding,
					}
				}
			end
		end--]]
	end

	local name = GameTextGetTranslatedOrNot(EntityGetName(selected_creature))
	local name_w,name_h = GuiGetTextDimensions(gui, name)

	local box_size = {
		x = edge_padding * 2 + math.max(icon_padding*math.max(math.min(#target_perks, 5)-1, 0) + math.min(#target_perks, 5) * icon_size, name_w),
		y = top_padding + name_h + edge_padding * 2 + icon_padding*math.max(math.ceil(#target_perks*.2)-1, 0) + math.ceil(#target_perks*.2) * icon_size,
	}

	local box_origin_x,box_origin_y = gui_x + x_offset_from_target, gui_y + y_offset_from_target
	if box_origin_x + box_size.x >= screen_width then box_origin_x = gui_x - (x_offset_from_target + box_size.x) end
	box_origin_y = math.max(math.min(box_origin_y, screen_height-box_size.y), 0)
	GuiZSetForNextWidget(gui, gz-4)
	GuiImageNinePiece(gui, new_id(), box_origin_x, box_origin_y, box_size.x, box_size.y)
	GuiText(gui, box_origin_x+edge_padding, box_origin_y+top_padding, name)

	local next_perk_x,next_perk_y,next_perk_num =
		box_origin_x+edge_padding,
		box_origin_y+top_padding+name_h+edge_padding,
		0

	for _,perk in ipairs(target_perks) do
		GuiZSetForNextWidget(gui, gz-5)
		render_perk(perk, next_perk_x, next_perk_y)
		next_perk_num = next_perk_num + 1
		if next_perk_num % max_perks_per_row == 0 then
			next_perk_x = box_origin_x+edge_padding
			next_perk_y = next_perk_y + icon_size + icon_padding
		else
			next_perk_x = next_perk_x + icon_size + icon_padding
		end
	end
end--]]

return hooks