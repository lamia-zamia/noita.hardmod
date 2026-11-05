function damage_about_to_be_received(damage, x, y, attacker, crit)
    if EntityHasTag(attacker, "player_unit") or EntityHasTag(attacker, "polymorphed_player") then
        return damage,crit
    end
end