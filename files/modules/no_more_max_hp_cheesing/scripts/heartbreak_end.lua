local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
utils.SetInternalInt(EntityGetRootEntity(GetUpdatedEntityID()), "hardmod_heartbreak_enabled", 0)
