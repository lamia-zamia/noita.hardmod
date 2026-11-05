local hooks = {} ---@type hooks

local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

local _g = HARDMOD_GLOBAL_DATA


--[[ NB-1: Spells To Crashes ]]
-- Fixes invalid values resulting in RAB malforming explosion radius. These malformed explosions can in semi-rare cases be large enough to instantly crash your game.

-- Yeah no this is the easiest fix in the world. This bug was undocumented pre-epi2 due to the plethora of other issues with the spell lmao.
local s2p = ModTextFileGetContent("data/scripts/projectiles/spells_to_power.lua")
if not s2p:find("ComponentObjectSetValue2") then
	ModTextFileSetContent("data/scripts/projectiles/spells_to_power.lua",
		"local ComponentObjectSetValue = ComponentObjectSetValue2\n\n" .. s2p
	)
end



--[[ NB-2: Malformed Jetpack Particle Height ]]
--<ParticleEmitterComponent::y_pos_offset_min/> is "" for these entities, this results in RAB causing the particle trail's height to be malformed.

local jetpack_targets = {
	"data/entities/base_jetpack_nosound.xml",
	"data/entities/animals/assassin.xml",
	"data/entities/animals/flamer.xml",
	"data/entities/animals/icer.xml",
	"data/entities/animals/necrobot_super.xml",
	"data/entities/animals/necrobot.xml",
	"data/entities/animals/spearbot.xml",
	"data/entities/misc/effect_farts.xml",
	"data/entities/misc/effect_rainbow_farts.xml",
	"data/entities/misc/player_drone_clone.xml",
	"data/scripts/streaming_integration/entities/effect_player_gas.xml",
}

-- Originally used NXML for this, but that's overkill. Unnecessary here.
for _,target in ipairs(jetpack_targets) do
	utils.modifile(target, [[y_pos_offset_min=""]], [[y_pos_offset_min=".5"]])
end
--0.5 looks nicer than 0 imo, we don't know what value Nolla would have written here so it is somewhat up to interpretation.



--[[ NB-3: Sungem Deload ]]

-- Implements a custom sungem check that also checks the materials in case the entity attached was destroyed.
for xml in nxml.edit_file("data/entities/animals/boss_centipede/ending/ending_sampo_spot_mountain.xml") do
	xml:add_children({
		nxml.parse_file("mods/noita.hardmod/files/modules/vanilla_bugfixes/sungems/sun_check.xml"),
		nxml.parse_file("mods/noita.hardmod/files/modules/vanilla_bugfixes/sungems/darksun_check.xml"),
	})
end

-- Disables the vanilla checks since we're reimplementing them, and doing both could potentially cause duplicate outcomes (instant supernova).
utils.modifile("data/scripts/magic/altar_tablet_magic.lua", [[GlobalsGetValue("MISC_SUN_EFFECT") ~= "1"]], [[false]])
utils.modifile("data/scripts/magic/altar_tablet_magic.lua", [[GlobalsGetValue("MISC_DARKSUN_EFFECT") ~= "1"]], [[false]])



--[[ NB-4: Permanent Item Stun Visuals ]]
-- The visuals caused by freeze-stun and electricity-stun effects can become permanent on a held item if you switch to a different item before the effect is up.

--[[ NB-5: Empty Death Message ]]
-- Sometimes the game does not provide a death message string, script_death here.

-- These two are just merged for efficiency so I don't need to add more than one LuaComponent to the player, will probably split if I eventually need to later.
for xml in nxml.edit_file("data/entities/player.xml") do
	xml:add_child(nxml.new_element("LuaComponent", {
		execute_every_n_frame = "6000", --fix stun visuals every 100 seconds.
		script_source_file = "mods/noita.hardmod/files/modules/vanilla_bugfixes/fix_permanent_stun_visual_items.lua", --Fix stun visuals script.
		script_death = "mods/noita.hardmod/files/modules/vanilla_bugfixes/fix_death_message/add_message.lua", --fix empty death message script.
		script_polymorphing_to = "mods/noita.hardmod/files/modules/vanilla_bugfixes/fix_death_message/add_message.lua", --Detect when the player polymorphs to apply the fix to their new form.
	}))
end

-- Script that activates when the player has been polymorphed to ensure the entity they polymorph into also has the death message fix applied.
local function fix_NB5(p, poly_identity)
	for _,luacomp in ipairs(EntityGetComponent(player, "LuaComponent") or {}) do
		if ComponentGetValue2(luacomp, "script_death") == "mods/noita.hardmod/files/modules/vanilla_bugfixes/fix_death_message/add_message.lua" then return end
	end --Check if the polymorphed player already has the script. If yes, then early return to halt the function.

	-- If the script is not detected on the player, apply the fix.
	EntityAddComponent2(player, "LuaComponent", {
		script_death = "mods/noita.hardmod/files/modules/vanilla_bugfixes/fix_death_message/add_message.lua",
		script_polymorphing_to = "mods/noita.hardmod/files/modules/vanilla_bugfixes/fix_death_message/add_message.lua",
	})
end



--[[ NB-6: Wrong Ending Spot ]]
---This bug I initially didn't understand, but with Letaali's guidance and rereading the code, I finally get it, if there is more than one mountain altar
--- loaded at a time, it will not check if the player is close to each of them, it will check if the player is close to the youngest one. This oversight
--- means that if an altar in Main World is loaded whilst the player is at a different mountain altar in a Parallel World, the game will only check the
--- youngest one and deduce that the player is not near the mountain altar, failing to trigger the mountain alter ending.
---This bug is a bit frustrating as it is so easily avoidable by either using `EntityGetClosestWithTag` instead of `EntityGetWithTag`, or by iterating over
--- the ending spots captured and identifying the closest one.
---Ideally this should be using EntityGetInRadiusWithTag(), but this would mess with some of the existing code, so simply using EntityGetClosestWithTag is
--- the simplest way to resolve this. Thank you to Letaali for illuminating this one for me, and allowing me to use his fix from the QoL mod.

--Solution is to do a manual check for the closest one and override the prior returns.
utils.modifile("data/entities/animals/boss_centipede/ending/sampo_start_ending_sequence.lua",
[[local endpoint_mountain = EntityGetWithTag( "ending_sampo_spot_mountain" )]],
[[local endpoint_mountain = EntityGetWithTag( "ending_sampo_spot_mountain" )
local hardmod_underground = EntityGetClosestWithTag( x, y, "ending_sampo_spot_underground" )
local hardmod_endpoint_mountain = EntityGetClosestWithTag( x, y, "ending_sampo_spot_mountain" )

if hardmod_underground ~= 0 then endpoint_underground[1] = hardmod_underground end
if hardmod_endpoint_mountain ~= 0 then endpoint_mountain[1] = hardmod_endpoint_mountain end
]])



--[[ NB-7: Non-Spinny Wands ]]
---After an enemy picks up a wand, the wand loses its spinning property, and does not regain it when held by a player.

--Bug appears to be solely due to this collection of wands that are either prefabs, or templates from which prefabs are derived.
-- First floor basically has a lot of prefab wands, a design approach Nolla swiftly abandoned. Fixing these should fix any other cases. Probably.
local non_spinny_wands = {
	"data/entities/items/wands/level_01/base_wand_level_1.xml",
	"data/entities/items/wands/level_01/wand_001.xml",
	"data/entities/items/wands/level_01/wand_002.xml",
	"data/entities/items/wands/level_01/wand_003.xml",
	"data/entities/items/wands/level_01/wand_004.xml",
	"data/entities/items/wands/level_01/wand_005.xml",
	"data/entities/items/wands/level_01/wand_006.xml",
	"data/entities/items/wands/level_01/wand_007.xml",
	"data/entities/items/wands/level_01/wand_008.xml",
	"data/entities/items/wands/level_01/wand_009.xml",
}

for _,wand in ipairs(non_spinny_wands) do
	utils.modifile(wand, [[play_spinning_animation="0"]], [[play_spinning_animation="1"]])
end



--[[ NB-8: Ungranted Modded Amulet Gem ]]
---Due to a feature(? bug??) wherein abandoning an ongoing run for a new one does not count as a death SPECIFICALLY in modded, an oversight (presumably) causes the
--- code that handles checking for the amulet gem run flag and granting the persistent flag to not run.

-- The solution here is to just manually grant the amulet gem when the ending is achieved, rather than forcing the player to find a way to perish.
utils.modifile("data/entities/animals/boss_centipede/ending/sampo_start_ending_sequence.lua",
	[[-- AddFlagPersistent( "secret_amulet_gem" )]], [[AddFlagPersistent( "secret_amulet_gem" )]]
)



--[[ NB-9: Crystal Key Global State Lock ]]
-- The Crystal Key tracks whether it has listened to a specific music machine via RunFlags, but the light/dark chests use the key's VariableStorageComponent to track completion.
-- This causes issues if you have the key listen to a machine and then loes that key, as a new key will think it's already listened to that machine, and not take in the song.

-- Add new <VariableStorageComponent/> to the key.
for xml in nxml.edit_file("data/entities/animals/boss_alchemist/key.xml") do
	xml:add_child(nxml.new_element("VariableStorageComponent", {
		_tags = "enabled_in_world",
		name = "hardmod_key_tracker",
		value_int = "0",
	}))
end

-- Prepend with our new function.
ModTextFileSetContent("data/entities/animals/boss_alchemist/key_music.lua",
	ModTextFileGetContent("mods/noita.hardmod/files/modules/vanilla_bugfixes/key_script_prepend.lua") .. ModTextFileGetContent("data/entities/animals/boss_alchemist/key_music.lua")
)

-- Replace flag check with our function.
utils.modifile("data/entities/animals/boss_alchemist/key_music.lua",
	[[GameHasFlagRun( mm_flag ) and ( GameHasFlagRun( mm_flag .. "_done" ) == false )]],
	[[update_music_machine_status(entity_id, mm_id)]]
)



--[[ NB-10: Failed Material Inheritance ]]

function hooks.edit_material(elem)
	if elem.attr._parent then elem.name = "CellDataChild" end
end



--[[ NB-11: Incorrect Dropper Bolt Charges ]]

for xml in nxml.edit_file("data/entities/misc/custom_cards/grenade.xml") do
	local base = xml:first_of("Base")
	if base then
		base:clear_children()
	end
end



--[[ NB-12: Telekinetic Kick Not Removable ]]

for xml in nxml.edit_file("data/entities/misc/perk_telekinesis.xml") do
	for elem in xml:each_child() do
		local tags = elem.attr._tags or ""
		if #tags > 0 then tags = tags .. ",telekinetic_kick" else tags = "telekinetic_kick" end
		elem.attr._tags = tags
	end
end

-- Remove all components with the `telekinetic_kick` tag.
utils.modifile("data/scripts/perks/perk_list.lua", [[-- TODO( Petri ): Remove the perk_telekinesis.xml stuff from the entity]],
				[[-- TODO( Petri ): Remove the perk_telekinesis.xml stuff from the entity
				-- TODONE( UserK ): Removed the perk_telekinesis.xml stuff from the entity
				for _,component in ipairs(EntityGetAllComponents(entity_who_picked) or {}) do
					if ComponentHasTag(component, "telekinetic_kick") then EntityRemoveComponent(entity_who_picked, component) end
				end]]
)



--[[ NB-14: Cursed Rock Biome Particle Issue ]]

for xml in nxml.edit_file("data/entities/misc/rock_curse.xml") do
	local pec = xml:first_of("ParticleEmitterComponent")
	if not pec then return end
	xml:remove_child(pec)


	--math to make the correct amount of particles depending on the size of the pec
	local full_size = 512
	local cuts = 4
	local particle_count = {min = 0, max = 1}
	--average of Random(3, 11)/500^2 for particle density in biome, doubled cuz amount is [0, 1], times 100 cuz integer [0-100] value.
	local emission_per_pixel = 0.0056
	if ModSettingGet("noita.hardmod.nerf_vanilla_cheeses.disabled") then
		full_size = 500
		cuts = 5
	end
	local segment_size = full_size/cuts
	local half_segment_size = segment_size * .5
	local minus_offset = (full_size * .5) + half_segment_size
	local emission_chance = math.floor((emission_per_pixel * segment_size^2) + .5) --multiply by area and then round.
	local attributes = pec.attr --create shorthand to reduce indexing.


	attributes["x_pos_offset_min"]	= tostring(-half_segment_size)
	attributes["x_pos_offset_max"]	= tostring(half_segment_size)
	attributes["y_pos_offset_min"]	= tostring(-half_segment_size)
	attributes["y_pos_offset_max"]	= tostring(half_segment_size)
	attributes["count_min"]			= tostring(particle_count.min)
	attributes["count_max"]			= tostring(particle_count.max)
	attributes["emission_chance"]	= tostring(emission_chance)


	for y = 1, cuts do
		for x = 1, cuts do
			xml:add_child(nxml.new_element("Entity", {name = x .. ", " .. y}, {
				nxml.new_element("InheritTransformComponent", {}, {
					nxml.new_element("Transform", {
						["position.x"] = x*segment_size-minus_offset,
						["position.y"] = y*segment_size-minus_offset,
					})
				}),
				pec,
			}))
		end
	end
end



--[[ NB-15: Whitehole Wrong Out Sprite ]]

utils.modifile("data/entities/projectiles/deck/white_hole.xml", [[data/particles/black_hole_out.xml]], [[mods/noita.hardmod/files/modules/vanilla_bugfixes/gfx/white_hole_out.xml]])



--[[ NB-71: Mists/Summoned Walls/Platforms Lack Tags ]]

local mists = {
	"data/entities/projectiles/deck/mist_alcohol.xml",
	"data/entities/projectiles/deck/mist_blood.xml",
	"data/entities/projectiles/deck/mist_radioactive.xml",
	"data/entities/projectiles/deck/mist_slime.xml",
}


for _,mist in ipairs(mists) do
	utils.modifile(mist, [[tags=""]], [[]]) --Remove redundant tags definition.
end



--[[ NB-270: GOLD NUGGET PICKUP LOG ]]
-- The log message from picking up gold nuggets does not account for the amount of greed stacks currently held by the player.

local list_of_nuggets = {
	"data/entities/items/pickup/goldnugget.xml",
	"data/entities/items/pickup/goldnugget_10.xml",
	"data/entities/items/pickup/goldnugget_50.xml",
	"data/entities/items/pickup/goldnugget_200.xml",
	"data/entities/items/pickup/goldnugget_1000.xml",
	"data/entities/items/pickup/goldnugget_10000.xml",
	"data/entities/items/pickup/goldnugget_200000.xml",
	"data/entities/items/pickup/goldnugget_x.xml",
}

local maybe_list_of_nuggets = {}

for _,maybe_nugget in ipairs(maybe_list_of_nuggets) do
	if ModDoesFileExist(maybe_nugget) then list_of_nuggets[#list_of_nuggets+1] = maybe_nugget end
end

local lua_comp = nxml.new_element("LuaComponent", {
	script_source_file = "mods/noita.hardmod/files/modules/vanilla_bugfixes/scripts/nugget_log_fix.lua",
	execute_on_added = "1",
	remove_after_executed = "1",
})

for _,nugget in ipairs(list_of_nuggets) do
	for xml in nxml.edit_file(nugget) do
		xml:add_child(lua_comp)
	end
end



--[[ NB-281: Missing Perk ]]
---In Holy Mountain, when entering a portal that's not one of the two directly above the Perk Altar, or if in the starting area above where you enter
--- the Holy Mountain and restarting/crashing, the third perk will be missing from the Perk Altar, on account of it being loaded into a chunk that was
--- not yet generated, causing it to not be saved.

-- Fix this by creating a singular entity created in the chunk the perks are spawned from to guarantee it's serialised, and then add the perks to it as children.
-- The perks will now be serialised as child entities under the group entity, group entity checks every 2f to see if both chunks are loaded.
-- If both chunks are loaded, the perk_group entity de-childs the perks and then deletes itself.

--Create our perk group entity.
utils.modifile("data/scripts/perks/perk.lua", [[for i=1,count do]],
	[[local perk_group = EntityLoad("mods/noita.hardmod/files/modules/vanilla_bugfixes/missing_perk/perk_group.xml", x, y)
	for i=1,count do]]
)

--Attach the perks to it.
utils.modifile("data/scripts/perks/perk.lua", [[perk_spawn( x + (i-0.5)*item_width, y, perk_id, dont_remove_others )]],
		[[local perk = perk_spawn( x + (i-0.5)*item_width, y, perk_id, dont_remove_others )
		if perk then EntityAddChild(perk_group, perk) end]]
)



--[[ NB-293: Attract Gold Is Weak ]]
-- Attract Gold is good at picking up $10 nuggets, bad with $50 nuggets and useless with anything larger.

-- Fix this by scaling the strength with mass (small gold nuggets are 25px, use it as a base).
utils.modifile("data/scripts/perks/attract_items.lua", [[
					local vel_x = math.cos( direction ) * power
					local vel_y = 0 - math.sin( direction ) * power]],[[
					local mass = ComponentGetValue2(physicscomponents[1], "mPixelCount") / 25
					if mass == 0 then mass = 25 end
					local vel_x = math.cos( direction ) * power * mass
					local vel_y = 0 - math.sin( direction ) * power * mass]]
)



--[[ NB-295: Polymorphed Player Lacks Drown SFX ]]
-- The sound loop that plays when drowning or taking curse damage is not applied to polymorphed player.

local function fix_NB295(p, poly_identity)
	if not poly_identity then return end

	if not (EntityGetComponent(_g.player, "AudioLoopComponent", "sound_suffocating") or EntityGetComponent(_g.player, "AudioLoopComponent", "sound_underwater")) then
		EntityAddComponent2(_g.player, "AudioLoopComponent", {
			_tags = "sound_underwater",
			file = "data/audio/Desktop/player.bank",
			event_name = "player/underwater",
			volume_autofade_speed = 0.25
		})
		EntityAddComponent2(_g.player, "AudioLoopComponent", {
			_tags = "sound_suffocating",
			file = "data/audio/Desktop/player.bank",
			event_name = "player/suffocating",
			volume_autofade_speed = 0.25
		})

		EntityAddComponent2(_g.player, "LuaComponent", {
			script_source_file = "mods/noita.hardmod/files/modules/vanilla_bugfixes/scripts/manage_suffocate_audio.lua"
		})
	end

	--if not EntityGetComponent(player, "AudioLoopComponent", "sound_damage_curse") then
	--	EntityAddComponent2(player, "AudioLoopComponent", {
	--		_tags = "sound_damage_curse",
	--		file = "data/audio/Desktop/player.bank",
	--		event_name = "player/underwater",
	--		volume_autofade_speed = 0.25
	--	})
	--end
end



--[[ NB-299: Brazilian Portuguese /Secrets Counter ]]
-- The number of discovered secrets in the progress menu on Brazilian Portuguese has a "/" before it.

utils.modifile("data/translations/common.csv", [[,$0/$1 segredos encontrados,]], [[,$0 $1 segredos encontrados,]])



--[[ NB-308: Twitchy Storage ]]
-- When the Twitchy game effect is removed it, it doesn't clear the player's <PlatformShooterPlayerComponent::mForceFireOnNextUpdate/>.
-- This forces the player to shoot their wand next time they switch to it despite the effect having run out.

for xml in nxml.edit_file("data/entities/misc/effect_twitchy.xml") do
	xml:add_child(nxml.new_element("LuaComponent", {
		script_source_file = "mods/noita.hardmod/files/modules/vanilla_bugfixes/scripts/remove_twitchy.lua",
		execute_every_n_frame = "-1",
		execute_on_removed = "1",
	}))
end



--[[ TRANSLATION FIXES ]]
--There are a few issues with translations, the main offenders being missing translations for death-messages and Kills To Mana's description being outdated.

--Note that for death messages, this specifically targets "invalid" or "incorrect" translations, ones with an invalid translation key, or point to the wrong one.
--Not to be confused with the bug that provides no translation key at all (both show up in-game as an empty death message, so they are easy to confuse).
--The fix for no death message being generated at all can be found below at [[ EMPTY DEATH MESSAGES ]] (it also tries to catch invalid death messages I miss here).

local translation_overrides = {
	--KILLS TO MANA DESCRIPTION: "perkdesc_mana_from_kills"
	-- The perk's description is an outright lie, likely outdated.
	-- Perk actually gives you 150f of MANA_REGENERATION when an enemy that has been within 240px of you dies.
	{ -- en
		target = [["Every time an enemy near you dies, you release mana-recharging liquid."]],
		new = [["You gain a short-lived boost to your mana regeneration when an enemy dies."]]
	},
	{ -- ru
		target = [["При каждой смерти ближайшего противника вы испускаете жидкость, пополняющую ману."]],
		new = [["Вы получаете кратковременный бонус к восстановлению маны при смерти врага."]]
	},--Thank you Rakaikkia
	{ -- fr-fr
		target = [["Chaque fois qu'un ennemi à proximité meurt, vous libérez un liquide rechargeant le mana."]],
		new = [["Gagne une régéneration de mana accrue pour une courte durée lorsqu'un ennemi meurt."]]
	},--Thank you Spode.
} -- Would be funny if these fan translations got into the game, just sayin' 👀

-- Add new translations, read common.csv for more individual info.
local translations = ModTextFileGetContent("data/translations/common.csv")
for _,value in ipairs(translation_overrides) do
	translations = translations:gsub(utils.escape(value.target), value.new)
end
ModTextFileSetContent("data/translations/common.csv", translations)

-- Fix the death messages caused by ghosts that follow Tapion Vasalli, "cursed rock" -> "holy"
utils.modifile("data/entities/animals/boss_spirit/wisp.xml", [["$damage_rock_curse"]], [["$damage_holy"]])
-- Fix the death messages caused by the Damage Field modifier, "cursed rock" -> "damage field"
utils.modifile("data/entities/misc/area_damage.xml", [["$damage_rock_curse"]], [["$hardmod_damage_projectile_area"]])
-- Fix the Propane Tank spell using a hardcoded name instead of its translation, "Propane tank" -> $action_propane_tank
utils.modifile("data/entities/misc/custom_cards/propane_tank.xml", [["Propane tank"]], [["$action_propane_tank"]])

-- Fix "bzzt!" death message from sawblades not being translatable, "bzzt!" -> "$hardmod_damage_sawblade"
local sawblade_targets = {
	"data/entities/projectiles/deck/disc_bullet_big.xml",
	"data/entities/projectiles/deck/disc_bullet_bigger.xml",
	"data/entities/misc/orbit_discs_disc.xml",
}
for _,file in ipairs(sawblade_targets) do
	utils.modifile(file, [["bzzt!"]], [["$hardmod_damage_sawblade"]])
end



--[[ UNSAVED PROGRESS FIX ]]
---When crashing in a run, the game will sometimes successfully remember which progress was discovered this run- but forget to have it permanently discovered.
---This results in locked portraits having a glowy border indicating they were discovered, but not actually saving them to the progress menu.

--Since the game is correctly remembering what has been discovered this run, and theoretically if someone discovered something "this run", then they must have
-- "discovered it" to begin with, we can just iterate over everything and force-discover everything that has been discovered this run.
function hooks.world_init()
	--Perks: These are the simplest cuz of how basic perk reflection is.
	RegisterPerk = function(id, ...)
		id = id:lower()
		if GameHasFlagRun("new_perk_picked_" .. id) then
			AddFlagPersistent("perk_picked_" .. id)
		end
	end
	dofile("data/scripts/perks/perk_reflect.lua")

	--Spells: Need to do these slightly more manually since the base system is kinda convoluted, I don't feel like deciphering it, I'll just make my own.
	dofile_once("data/scripts/gun/gun.lua")
	for _,action in ipairs(actions or {}) do
		local id = action.id:lower()
		if GameHasFlagRun("new_action_" .. id) then
			AddFlagPersistent("action_" .. id)
		end
	end

	--Enemies: We have no ability to read from or write to enemy stats, as they are stored within `Noita/save_stats/`, and we do not have an API function to interact
	-- with them like we do `Noita/save00/persistent/flags/` via `HasPersistentFlag()`/`AddPersistentFlag()`.
end
--This approach might theoretically be undesirable for a mod that intentionally has things discovered "this run" while not permanently marking them as discovered.
-- If such a case were to occur, I may end up taking out this fix and relegating it to my Extended Fixes mod, we shall see.


function hooks.player_changed(p, poly_identity)
	fix_NB5(p, poly_identity)
	fix_NB295(p, poly_identity)
end

return hooks