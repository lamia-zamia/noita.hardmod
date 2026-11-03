local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

local orig_damage_received = damage_received
local delay_frames = 10

function damage_received(...)
  local eid = GetUpdatedEntityID()

  local frame = GameGetFrameNum()
  local last = utils.GetInternalInt(eid, "last_dmg_at") or 0

  if frame - last < delay_frames then
    return
  end

  -- activate the shield
  local shield = EntityGetAllChildren( eid, "hardmod_gold_shield" )[1]
  if shield ~= nil then
    utils.SetInternalInt( shield, "hardmod_gold_shield_trigger_frame", GameGetFrameNum() )
    EntitySetComponentsWithTagEnabled( shield, "hardmod_gold_shield_active", true )
    EntitySetComponentsWithTagEnabled( shield, "hardmod_gold_shield_inactive", false )
    local x, y = EntityGetTransform( shield )
    GamePlaySound( "data/audio/Desktop/projectiles.bank", "player_projectiles/shield/activate", x, y )
  else
    EntityAddComponent2( eid, "LuaComponent", {
      script_source_file = "mods/noita.hardmod/files/modules/vanilla_bosses/scripts/boss_pit_on_spawn.lua",
      execute_every_n_frame = 1,
      remove_after_executed = true,
    } )
  end

  utils.SetInternalInt(eid, "last_dmg_at", frame)
  orig_damage_received(...)
end
