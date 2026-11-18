local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

utils.SetInternalInt(GetUpdatedEntityID(), "spawn_frame", GameGetFrameNum())
