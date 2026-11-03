-- TODO: make a mod :)
-- Eba was here!!!
-- UserK too!!
-- !!!ooT enyL AgnoC
-- D2D2
-- qtyui_ too!!!!

local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

local modules = {
	"test_module_dont_run",
	"example",
	"nerfed_combat_healing",
	"enemy_perks",
	"trappier_traps",
	"cheeseless_triggers",
	"logo_splash",
	"starter_wands",
	"unshuffle",
	"vanilla_perk_rebalances",
	"vanilla_spell_rebalances",
	"vanilla_quests",
	"vanilla_bosses",
	--"no_more_chainsaw_wrapping", -- shit module never enable
	"less_explosive",
	"holy_mountain_rework",
	"holy_mountain_items",
	"ring_of_returning",
	"no_more_max_hp_cheesing",
	"phantom_nemesis",
	"alt_fire_anything",
	"ending",
	"credits",
	"nerf_vanilla_cheeses",
	"nerf_vanilla_damage",
	-- replaced by `ending` module requiring 11 orbs to pickup sampo
	-- "stronger_kolmi",
	"chest_tweaks",
	"better_anvil",
	"rapidfire_nerfs",
	"trial_perks",
	"biome_map",
	"biome_modifiers",
	"wizards",
	"stronger_enemies",
	"potions",
	"alternate_biomes",
	"polymorph_gui",
	"vanilla_bugfixes",
}

local force_enable_state = {
	test_module_dont_run = false,
	example = false,
}


local enabled_modules = {}
for _,module in ipairs(modules) do
	local enabled = not ModSettingGet("noita.hardmod."..module..".disabled")
	if force_enable_state[module] ~= nil then enabled = force_enable_state[module] end
	if enabled then
		enabled_modules[#enabled_modules+1] = module
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
	player_poly_identity = nil, --contains some data on the player if they are polymorphed, nil if not polymorphed.
	player_does_not_exist = true, --this is set to false on `player_spawned` and set to true on `player_destroyed`.

	frame = 0,
}
local gd = HARDMOD_GLOBAL_DATA

ModTextFileSetContent("mods/noita.hardmod/files/__spell_appends.lua", "--")
ModTextFileSetContent("mods/noita.hardmod/files/__perk_appends.lua", "--")

for _,module in ipairs(enabled_modules) do
	local module_path = table.concat({"mods/noita.hardmod/files/modules/",module,"/"})
	local module_hooks = dofile(module_path.."init.lua") or {}
	for hook_name,hook in pairs(module_hooks) do
		if hooks[hook_name] ~= nil then --Throw that shit away, let me stuff random shit in the hooks table >:(
			hooks[hook_name][#hooks[hook_name]+1] = hook
		end
	end

	local spell_append_path = module_path..(module_hooks.spells_path or "spells.lua")
	if ModDoesFileExist(spell_append_path) then
		ModLuaFileAppend("mods/noita.hardmod/files/__spell_appends.lua", spell_append_path)
	end

	local perk_append_path = module_path..(module_hooks.perks_path or "perks.lua")
	if ModDoesFileExist(perk_append_path) then
		print("appending...")
		ModLuaFileAppend("mods/noita.hardmod/files/__perk_appends.lua", perk_append_path)
	end
end

ModLuaFileAppend("data/scripts/gun/gun_actions.lua", "mods/noita.hardmod/files/scripts/spells.lua")
ModLuaFileAppend("data/scripts/perks/perk_list.lua", "mods/noita.hardmod/files/scripts/perks.lua")

local translations = ModTextFileGetContent("data/translations/common.csv")
translations = translations .. "\n" .. ModTextFileGetContent("mods/noita.hardmod/files/standard.csv").."\n"
translations = translations:gsub("\r", ""):gsub("\n\n+", "\n")
ModTextFileSetContent("data/translations/common.csv", translations)


-- remove perks with not_progress from progress menu
utils.modifile("data/scripts/perks/perk_reflect.lua",
[[	RegisterPerk( 
		perk.id,
		perk.ui_name,
		perk.ui_description,
		perk.ui_icon,
		perk.perk_icon
		)]],
[[	if not perk.not_progress then RegisterPerk( 
		perk.id,
		perk.ui_name,
		perk.ui_description,
		perk.ui_icon,
		perk.perk_icon
		) end]])

utils.patchifile("data/scripts/gun/gun_collect_metadata.lua", {
	{
		from = [[register_action( c )]],
		insert_before = [[ if not action.not_progress then ]],
		insert_after = [[ end ]]
	}
})

function OnModPreInit()
	for _,func in ipairs(hooks.mod_pre_init) do
		func()
	end
end
function OnModInit()
	for _,func in ipairs(hooks.mod_init) do
		func()
	end
end
function OnModPostInit()
	for _,func in ipairs(hooks.mod_post_init) do
		func()
	end
end

function OnMagicNumbersAndWorldSeedInitialized() -- this is the last point where the Mod* API is available. after this materials.xml will be loaded.
	SetRandomSeed(-2497, 492)
	for _,func in ipairs(hooks.magic_numbers_and_seed_initialised) do
		func()
	end

	-- this code adds tags to preexisting materials, its good for compatibility
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

function OnBiomeConfigLoaded()
	for _,func in ipairs(hooks.biome_config) do
		func()
	end
end

function OnWorldInitialized()
	for _,func in ipairs(hooks.world_init) do
		func()
	end
end


function OnPlayerSpawned(p)
	gd.player = p
	gd.player_does_not_exist = false
	local is_run_start = not GameHasFlagRun("noita.hardmod.on_player_spawned_flag")
	for _,func in ipairs(hooks.player_spawned) do
		func(p, is_run_start)
	end

	GameAddFlagRun("noita.hardmod.on_player_spawned_flag")
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
local check_entities = function()
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
			else
				if EntityHasTag(i, "polymorphed_player") then
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
			end
			::continue::
		end
		for _,func in ipairs(hooks.new_eid) do
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
	check_entities()

	for _,func in ipairs(hooks.pre_update) do
		func(gd.frame)
	end
end

function OnWorldPostUpdate()
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
