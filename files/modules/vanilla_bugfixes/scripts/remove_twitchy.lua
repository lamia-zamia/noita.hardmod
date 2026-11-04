local root = EntityGetRootEntity(GetUpdatedEntityID())

local shooter_player_comp = EntityGetFirstComponentIncludingDisabled(root, "PlatformShooterPlayerComponent")
if shooter_player_comp then
    ComponentSetValue2(shooter_player_comp, "mForceFireOnNextUpdate", false)
end