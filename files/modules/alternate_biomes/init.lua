local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua")---@type nxml
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils
local alt_biomes = dofile_once("mods/noita.hardmod/files/modules/alternate_biomes/biome_list.lua")
local hooks = {}---@type hooks

local dir = "mods/noita.hardmod/files/modules/alternate_biomes/"

ModMaterialsFileAdd(dir.."materials/materials.xml")

local materials = ModTextFileGetContent("data/materials.xml")
materials = materials:gsub('(%sname="fungal_gas")', '%1 liquid_stains="1" liquid_sprite_stains_check_offset="1" liquid_sprite_stains_status_threshold="0.25"', 1)
materials = materials:gsub('(%sname="fungal_gas".-)(</CellDataChild>)', '%1\t<StatusEffects>\n\t\t<Stains>\n\t\t\t<StatusEffect type="TRIP" />\n\t\t</Stains>\n\t</StatusEffects>\n%2', 1)
materials = materials:gsub('(%sname="blood_fungi".-)%sstatus_effects="SLIMY"', '%1', 1)
materials = materials:gsub('(%sname="blood_fungi".-<StatusEffects>)', '%1\n\t\t<Stains>\n\t\t\t<StatusEffect type="SLIMY" />\n\t\t\t<StatusEffect type="TRIP" />\n\t\t</Stains>', 1)
ModTextFileSetContent("data/materials.xml", materials)

ModLuaFileAppend("mods/noita.hardmod/lib/biome_index.lua",
	dir.."scripts/append_biomes_to_index.lua"
)
ModLuaFileAppend("data/scripts/biome_map.lua", dir.."scripts/append_biome_map.lua")
ModLuaFileAppend("mods/noita.hardmod/files/modules/biome_map/biome_map.lua", dir.."scripts/append_biome_map.lua")

if ModIsEnabled("component-explorer") then
	ModLuaFileAppend("mods/component-explorer/spawn_data/creatures.lua", dir.."scripts/ce_creatures.lua")
end

utils.AddEnemyToProgress("hardmod_fungal_longleg", "longleg")
utils.AddEnemyToProgress("hardmod_fungal_zombie", "zombie_weak")
utils.AddEnemyToProgress("hardmod_fungal_slimeshooter", "slimeshooter_weak")
utils.AddEnemyToProgress("hardmod_fungal_acidshooter", "acidshooter_weak")
utils.AddEnemyToProgress("hardmod_fungal_giantshooter", "giantshooter_weak")
utils.AddEnemyToProgress("hardmod_fungal_miner", "miner_weak")
utils.AddEnemyToProgress("hardmod_fungal_shotgunner", "shotgunner_weak")
utils.AddEnemyToProgress("hardmod_fungal_firemage", "firemage_weak")
utils.AddEnemyToProgress("hardmod_fungal_worm", "worm")
utils.AddEnemyToProgress("hardmod_fungal_skull", "fireskull")
utils.AddEnemyToProgress("hardmod_fungal_shaman", "shaman")
utils.AddEnemyToProgress("hardmod_fungal_alchemist", "alchemist")
utils.AddEnemyToProgress("hardmod_fungal_thundermage", "thundermage")

for xml in nxml.edit_file("data/biome/_biomes_all.xml") do
	for _,alt_biome in ipairs(alt_biomes) do
		xml:add_child(nxml.new_element("Biome", {
			biome_filename = table.concat({dir,"biomes/",alt_biome.biome,".xml"}),
			height_index = "1",
			color = ("%x"):format(alt_biome.colour_id),
		}))
		print(("%x"):format(alt_biome.colour_id))
	end
end

local player_scripts = {
	{
		field = "script_source_file",
		values = {
			script_source_file = dir.."scripts/fungal_gas_stain.lua",
			execute_every_n_frame = 1,
		},
	},
	{
		field = "script_damage_received",
		values = {
			script_damage_received = dir.."enemies/fungal/zombie/scripts/trip_on_hit.lua",
			execute_every_n_frame = -1,
		},
	},
}

local function add_player_scripts(player)
	if player == nil or not EntityGetIsAlive(player) then
		return
	end
	local comps = EntityGetComponentIncludingDisabled(player, "LuaComponent") or {}
	for _,script in ipairs(player_scripts) do
		local path = script.values[script.field]
		local found = false
		for _,comp in ipairs(comps) do
			if ComponentGetValue2(comp, script.field) == path then
				found = true
				break
			end
		end
		if not found then
			EntityAddComponent2(player, "LuaComponent", script.values)
		end
	end
end

hooks.player_spawned = add_player_scripts
hooks.player_changed = add_player_scripts

return hooks
