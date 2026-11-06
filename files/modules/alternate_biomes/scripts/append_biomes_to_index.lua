return function(simple_id_list, exact_path_list)
    simple_id_list["mods/noita.hardmod/files/modules/alternate_biomes/biomes/fungal_mines.xml"] = "mines"
    simple_id_list["mods/noita.hardmod/files/modules/alternate_biomes/biomes/sand_pits.xml"] = "coal_pits"

    exact_path_list.hardmod_infested_mines = "mods/noita.hardmod/files/modules/alternate_biomes/biomes/fungal_mines.xml"
    exact_path_list.hardmod_deserted_pits = "mods/noita.hardmod/files/modules/alternate_biomes/biomes/sand_pits.xml"
end