return {
    new_spells = {
        {
            id                = "HARDMOD_ALT_FIRE_ANYTHING",
            name              = "$hardmod_spell_alt_fire_anything_name",
            description       = "$hardmod_spell_alt_fire_anything_desc",
            sprite            = "mods/noita.hardmod/files/modules/alt_fire_anything/ui_gfx/spells/alt_fire_anything.png",
            type              = ACTION_TYPE_PASSIVE,
            spawn_level       = "1,2,3,4,5,6,10",
            spawn_probability = "0.2,0.4,0.6,0.8,1,1,1",
            custom_xml_file   = "mods/noita.hardmod/files/modules/alt_fire_anything/entities/custom_cards/card_alt_fire_anything.xml",
            price             = 400,
            mana              = 0,
            action = function()
                while #deck > 0 do
                    local data = deck[1]
                    ---@diagnostic disable-next-line: inject-field
                    data.in_fake_hand = true
                    table.insert(hand, data)
                    table.remove(deck, 1)
                end
                draw_actions(1, true)
            end,
        },
    }
}