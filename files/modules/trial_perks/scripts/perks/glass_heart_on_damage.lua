local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

function damage_received( damage, message, entity_thats_responsible, is_fatal, projectile_thats_responsible )
	local responsible_entity_tags = EntityGetTags( entity_thats_responsible )
    local responsible_entity_is_mortal = responsible_entity_tags and string.find( responsible_entity_tags, "mortal" )

    if ( responsible_entity_is_mortal or projectile_thats_responsible ~= 0 ) and damage > 0 then
        local owner = GetUpdatedEntityID()
        local x, y = EntityGetTransform( owner )

		GamePlaySound( "data/audio/Desktop/misc.bank", "game_effect/frozen/damage", x, y )
		GamePrintImportant( "The Glass Heart shattered" )

        dofile_once( "mods/noita.hardmod/files/modules/trial_perks/scripts/trial_perk_utils.lua" )
        utils.EntityRemoveAllByTag( owner, "hardmod_glass_heart" )
        SwapPerkIconForSpent( owner, "$hardmod_perk_glass_heart_name", false )
        utils.SetInternalInt( owner, "hardmod_glass_heart_start_y", 0 )
	end
end
