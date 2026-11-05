---@class hooks
local hooks = {
	--Game/World Initialising
	mod_pre_init = function() end, --`OnModPreInit()`
	mod_init = function() end, --`OnModInit()`
	mod_post_init = function() end, --`OnModPostInit()`
	magic_numbers_and_seed_initialised = function() end, --`OnMagicNumbersAndWorldSeedInitialised()`
	edit_material = function(elem) end, --iterates over all materials OnMagicNumbersAndWorldSeedInitialised
	edit_reaction = function(elem) end, --iterates over all reactions OnMagicNumbersAndWorldSeedInitialised
	biome_config = function() end, --`()`
	world_init = function() end, --`OnWorldInitialized()`

	--Runtime hofunction() ends
	pre_update = function(frame) end, --beginning of every frame
	new_eid = function(entity_id) end, --new entity
	post_update = function(frame) end, --end of every frame

	--Player hofunction() ends
	player_spawned = function(player, is_run_start) end, --When the player spawns in after world is initialised
	player_changed = function(player, poly_identity) end, --Runs whenever polymorphing/unpolymorphing
	player_destroyed = function(player) end, --OnPlayerDied

	--Pause hofunction() ends
	mod_settings_changed = function() end,
	pause_pre_update = function() end,
	pause_changed = function(is_paused, is_inventory_pause) end,
	count_secrets = function(total, found) return total,found end, --runs every frame on the progress menu, `found` is added to the secrets counter
}

-- DONT INITIALISE FUNCTIONS YOU DONT NEED, THESE ARE JUST HERE TO SHOW YOU A LIST OF THEM ^^^^

local gd = HARDMOD_GLOBAL_DATA

gd.player = nil --This is the player's Entity ID, it is updated before player_spawned, player_changed and player_destroyed and directly passed to all 3 functions.
gd.player_poly_identity = nil --This is the player's Polymorph Identity, it is updated before player_changed and directly passed into it.
gd.player_does_not_exist = true --This is whether or not the player currently exists, it is set to true on player_spawned and false on player_destroyed.
gd.frame = 0 --This is the current frame, it is updated before pre_update and is directly passed to pre_update and post_update.


--These are just the standard init functions, they are almost never used but can be helpful if running into load-order issues
hooks.mod_pre_init = function() end
hooks.mod_init = function() end
hooks.mod_post_init = function() end

hooks.magic_numbers_and_seed_initialised = function() end --The world seed is now initialised, meaning the Random functions are now available
hooks.edit_material = function(material)
    --This function is iterated over every material (including modded) and passes the XML data for the material as an NXML Element.
    --Modfying the `material` variable will modify the core material.
    if material.attr.name == "magic_liquid_confusion" then
        material.attr.electrical_conductivity = "0" --make flummoxium no longer conductive
    end
end
hooks.biome_config = function() end --Runs when biome data is initialised (runs just after Biome Modifiers are decided).
hooks.world_init = function() end --Runs when the world (including WSE) is initialised.

hooks.pre_update = function(frame) end --Runs at the start of every frame.
hooks.new_eid = function(entity_id, varcomp_tree)
    --This function iterates over every new entity that has been created at the start of a frame.
    if GameHasFlagRun("spawn_more_enemies") and (EntityHasTag(entity_id, "enemy") and not EntityHasTag(entity_id, "boss")) then
        SetRandomSeed(-entity_id, gd.frame)
        if Random(1,5) == 1 then
            local x,y = EntityGetTransform(entity_id)
            EntityLoad(EntityGetFilename(entity_id), x, y)
        end
    end --example function that makes it so all enemies that spawn have a 20% chance to spawn another enemy.
end
hooks.post_update = function(frame) end --Runs at the end of every frame.

hooks.player_spawned = function(player, is_start_of_run)
    --Runs when the player loads into the game.
    --This runs on game restart, is_start_of_run will only be true if this is the first time the player has loaded into this run
end
hooks.player_changed = function(player, poly_identity)
    --This runs whenever the player Polymorphs or Unpolymorphs.
    --`player` is the player's new Entity ID, `poly_identity` is a table of `path` being the polymorph target's filepath and `name` being the current name of the entity
end
hooks.player_destroyed = function(player)
    --Runs when the player entity is destroyed.
    --At this point the player's death cannot be stopped, however the entity data still exists and can be read accordingly.
end

hooks.mod_settings_changed = function() end --OnModSettingsChanged
hooks.pause_pre_update = function() end --runs every frame while the game is paused
hooks.pause_changed = function(is_paused, is_inventory_pause) end --OnPauseChanged
hooks.count_secrets = function(total, found)
    --Runs every frame when the progress menu is open.
    total = total + 1
    if HasFlagPersistent("noita_hardmod_awesome_secret") then
        found = found + 1
    end
    return total,found --don't forget to return!!
end

return hooks --Don't forget to do this if you want your changes to apply!!!!