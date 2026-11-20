-- TODO: make a mod :)
-- Eba was here!!!
-- UserK too!!
-- !!!ooT enyL AgnoC
-- D2D2
-- qtyui_ too!!!!

-------------------------
--testing zone


ModSettingSet("noita.hardmod.snail.disabled", true) --This module causes crashes, need to fix


-------------------------



local nxml_missing
if not ModDoesFileExist("mods/noita.hardmod/lib/nxml/nxml.lua") then
	ModTextFileSetContent("mods/noita.hardmod/lib/nxml/nxml.lua", ModTextFileGetContent("mods/noita.hardmod/files/scripts/nxml_backup.lua"))
	nxml_missing = true
end

local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

local modules = dofile_once("mods/noita.hardmod/modules.lua")---@type module_list

local enabled_modules = {}
for _,name in ipairs(modules.list) do
	local enabled = not ModSettingGet("noita.hardmod."..name..".disabled")
	if enabled then
		enabled_modules[#enabled_modules+1] = name
	end
end


local hooks = {
	--Game/World Initialising
	mod_pre_init = {}, --OnModPreInit
	mod_init = {}, --OnModInit
	mod_post_init = {}, --OnModPostInit
	magic_numbers_and_seed_initialised = {}, --OnMagicNumbersAndWorldSeedInitialized
	edit_material = {}, --iterates over all materials after magic_numbers_and_seed_initialised
	edit_reaction = {}, --(DISABLED UNTIL NEEDED) iterates over all reactions after magic_numbers_and_seed_initialised
	biome_config = {}, --OnBiomeConfigLoaded
	world_init = {}, --OnWorldInitialised

	--Runtime hooks
	pre_update = {}, --OnWorldPreUpdate (start of every frame)
	new_eid = {}, --on new entity created after pre_update
	post_update = {}, --OnWorldPreUpdate (end of every frame)

	--Player hooks
	player_spawned = {}, --OnPlayerSpawned
	player_changed = {}, --on player polymorphed/unpolymorphed
	player_destroyed = {}, --OnPlayerDied

	--Pause hooks
	mod_settings_changed = {}, --OnModSettingsChanged
	pause_pre_update = {}, --OnPausePreUpdate
	pause_changed = {}, --OnPausedChanged
	count_secrets = {}, --OnCountSecrets
}

HARDMOD_GLOBAL_DATA = { ---@class HardmodGlobalInitData
	player = nil, --player EID.
	---@type { path: string, name: string }?
	player_poly_identity = nil, --contains some data on the player if they are polymorphed, nil if not polymorphed.
	player_does_not_exist = true, --this is set to false on `player_spawned` and set to true on `player_destroyed`.

	frame = 0,
}
local gd = HARDMOD_GLOBAL_DATA

ModTextFileSetContent("mods/noita.hardmod/files/__spell_appends.lua", "--")
ModTextFileSetContent("mods/noita.hardmod/files/__perk_appends.lua", "--")

---If this table is not empty, a tablet containing all the strings in init_errors will be spawned on top of the player
---@type string[]
local init_error_lines = {}

---@param err string
local function add_init_error(err)
	for line in err:gmatch("[^\n]+") do
		table.insert(init_error_lines, line)
	end
	print("[noita.hardmod] [ERROR]", err)
end

local function add_module(module)
	local module_path = table.concat({"mods/noita.hardmod/files/modules/",module,"/"})

	if not ModDoesFileExist(module_path.."init.lua") then
		add_init_error("Module "..module..": init.lua does not exist")
		return
	end

	local module_hooks = dofile_once(module_path.."init.lua") or {}

	local spell_append_path = module_path..(module_hooks.spells_path or "spells.lua")
	if ModDoesFileExist(spell_append_path) then
		ModLuaFileAppend("mods/noita.hardmod/files/__spell_appends.lua", spell_append_path)
	end

	local perk_append_path = module_path..(module_hooks.perks_path or "perks.lua")
	if ModDoesFileExist(perk_append_path) then
		ModLuaFileAppend("mods/noita.hardmod/files/__perk_appends.lua", perk_append_path)
	end

	for hook_name,hook in pairs(module_hooks) do
		if hooks[hook_name] then
			hooks[hook_name][#hooks[hook_name]+1] = hook
		end
	end
end

--- Note: Only do this for init hooks!!!!
local function try_run_hooks(hook_name, ...)
	if type(hooks[hook_name]) ~= "table" then
		add_init_error("Hook "..hook_name..": invalid hook name?!?!")
		return
	end

	for _,func in pairs(hooks[hook_name]) do
		local succ, res = pcall(func, ...)
		if not succ then
			add_init_error("Hook "..hook_name..": "..tostring(res))
		end
	end
end

local function patch_materials()
	local files = ModMaterialFilesGet()
	for _, file in ipairs(files) do --add modded materials
		for xml in nxml.edit_file(file) do
			for elem in xml:each_child() do
				local elem_name = elem.name
				if elem_name == "CellData" or elem_name == "CellDataChild" then
					for _,func in ipairs(hooks.edit_material) do
						func(elem)
					end
				else
					--for _,func in ipairs(hooks.edit_reaction) do
					--	func(elem)
					--end disabled until someone actually needs it for something
				end
			end
		end
	end
end

for _,module in ipairs(enabled_modules) do
	print("[noita.hardmod] Adding module: "..module)

	local success, res = pcall(add_module, module)
	if not success then
		add_init_error("Module "..module..": "..tostring(res))
	end
end


ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/noita.hardmod/files/scripts/spells.lua")
ModLuaFileAppend("data/scripts/perks/perk_list.lua", "mods/noita.hardmod/files/scripts/perks.lua")


dofile("mods/noita.hardmod/files/translations/debug_split.lua")
local translations = ModTextFileGetContent("data/translations/common.csv")
translations = translations .. "\n" .. ModTextFileGetContent("mods/noita.hardmod/files/translations/standard.csv").."\n"
translations = translations:gsub("\r", ""):gsub("\n\n+", "\n")
ModTextFileSetContent("data/translations/common.csv", translations)



function OnModPreInit() try_run_hooks("mod_pre_init") end
function OnModInit() try_run_hooks("mod_init") end
function OnModPostInit() try_run_hooks("mod_post_init") end

function OnMagicNumbersAndWorldSeedInitialized() -- this is the last point where the Mod* API is available. after this materials.xml will be loaded.
	SetRandomSeed(-2497, 492)

	-- ok but who called this initialiSed, its initialiZed smh my head!!! :(
	try_run_hooks("magic_numbers_and_seed_initialised")

	-- This one uses pcall on the entire procedure rather than each hook call for performance reasons
	local succ, res = pcall(patch_materials)
	if not succ then
		add_init_error("Error patching materials: "..tostring(res))
	end
end

function OnBiomeConfigLoaded() try_run_hooks("biome_config") end
function OnWorldInitialized() try_run_hooks("world_init") end

function OnPlayerSpawned(pid)
	gd.player = pid
	gd.player_does_not_exist = false

	local is_run_start = not GameHasFlagRun("noita.hardmod.on_player_spawned_flag")
	if is_run_start and not EntityGetFirstComponent(pid, "BiomeTrackerComponent") then
		EntityAddComponent2(pid, "BiomeTrackerComponent")
	end

	try_run_hooks("player_spawned", pid, is_run_start)
	GameAddFlagRun("noita.hardmod.on_player_spawned_flag")

	if nxml_missing then GamePrint("$hardmod_nxml_missing") end

	if #init_error_lines > 0 then
		local lines = {}
		local max_width = 80
		for _,line in pairs(init_error_lines) do
			if #line > 0 then
				for i=1,#line,max_width do
					table.insert(lines, line:sub(i, i + max_width + 1))
				end
			else table.insert(lines, "") end
		end

		local x, y = EntityGetTransform(pid)
		utils.SpawnTablet(
			x, y, "Noita Hard Mod: Errors occurred!!!",
			table.concat(lines, "\n"):sub(1, 2000)
		)
	end
end

function OnPlayerDied(p)
	gd.player_does_not_exist = true
	gd.player = nil
	gd.player_poly_identity = nil
	for _,func in ipairs(hooks.player_destroyed) do
		func(p)
	end
end

local prev_max_eid = -1
local max_eid = -1
local check_entities = function(is_post)
	local old_player = gd.player
	local borked_polymorph_entity
	if not (gd.player_does_not_exist or EntityGetIsAlive(gd.player)) then
		max_eid = prev_max_eid --rollback in case EntityGetIsAlive was outdated by 1 frame (happens).
		gd.player = nil
	end

	local new_max = EntitiesGetMaxID()
	---@type entity_id
	for i = max_eid + 1, new_max do
		if not (gd.player or gd.player_does_not_exist) then
			if EntityHasTag(i, "player_unit") then
				gd.player = i
				gd.player_poly_identity = nil
			elseif EntityHasTag(i, "polymorphed_player") then
				gd.player = i
				gd.player_poly_identity = {
					path = EntityGetFilename(i),
					name = EntityGetName(i)
				}
			else
				for _,comp in ipairs(EntityGetComponent(i, "GameStatsComponent") or {}) do
					if ComponentGetTypeName(comp) ~= "GameStatsComponent" then --Check if GSC is bugged (store as backup if yes)
						borked_polymorph_entity = borked_polymorph_entity or i
						goto continue
					elseif ComponentGetValue2(comp, "is_player") then
						gd.player = i
						gd.player_poly_identity = {
							path = EntityGetFilename(i),
							name = EntityGetName(i)
						}
						goto continue
					end
				end
			end
			::continue::
		end
		local hooks_target = is_post and hooks.new_eid_post or hooks.new_eid
		for _,func in ipairs(hooks_target) do
			--Unused system for generating a table of all the entity's VariableStorageComponent data, shelved until it seems like it'd be actually useful
			--local varcomp_tree = {}
			--for _,varcomp in ipairs(EntityGetComponent(i, "VariableStorageComponent") or {}) do
			--	local name = ComponentGetValue2(varcomp, "name")
			--	varcomp_tree[name] = varcomp_tree[name] or {}
			--	varcomp_tree[name][#varcomp_tree[name]+1] = varcomp
			--end

			func(i)
		end
	end
	prev_max_eid = max_eid --we store prev max eid in case a rollback is necessary due to frame delay nonsense with EntityGetIsAlive.
	max_eid = new_max

	if old_player ~= gd.player then
		if gd.player == nil and borked_polymorph_entity then
			gd.player = borked_polymorph_entity
			gd.player_poly_identity = {
				path = EntityGetFilename(gd.player),
				name = EntityGetName(gd.player)
			}
		end
		if gd.player ~= nil then
			for _,func in ipairs(hooks.player_changed) do
				func(gd.player, gd.player_poly_identity)
			end
		end
	end
end

function OnWorldPreUpdate()
	gd.frame = GameGetFrameNum()
	SetRandomSeed(-2497, 492-gd.frame) --maybe fixes stale-randomness issues?
	check_entities(false)

	for _,func in ipairs(hooks.pre_update) do
		func(gd.frame)
	end
end

function OnWorldPostUpdate()
	check_entities(true)
	for _,func in ipairs(hooks.post_update) do
		func(gd.frame)
	end
end


function OnModSettingsChanged()
	for _,func in ipairs(hooks.mod_settings_changed) do
		func()
	end
end

function OnPausePreUpdate()
	for _,func in ipairs(hooks.pause_pre_update) do
		func()
	end
end

function OnPausedChanged(is_paused, is_inventory_pause)
	for _,func in ipairs(hooks.pause_changed) do
		func(is_paused, is_inventory_pause)
	end
end

function OnCountSecrets(total, found)
	for _,func in ipairs(hooks.count_secrets) do
		total, found = func(total, found)
	end
	return total, found
end
