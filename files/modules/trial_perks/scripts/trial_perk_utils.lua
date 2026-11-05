
--- Swaps a perk's default icon with that of the spent perk
---@param player_id entity_id The player's entity_id
---@param perk_name string The... name of the perk
---@param use_passed_icon boolean If enabled, x_passed.png becomes the new icon (instead of x_spent.png)
function SwapPerkIconForSpent( player_id, perk_name, use_passed_icon )
    for i,child_id in ipairs( EntityGetAllChildren( player_id ) or {} ) do
        if EntityHasTag( child_id, "perk_entity" ) then
            local iconcomp = EntityGetFirstComponent( child_id, "UIIconComponent" )
            if iconcomp ~= nil then
                local comp_name = ComponentGetValue2( iconcomp, "name" )
                if string.find( comp_name, perk_name ) then
                    local current_sprite_file = ComponentGetValue2( iconcomp, "icon_sprite_file" )

                    local suffix = ""
                    if use_passed_icon then suffix = "_passed.png" else suffix = "_spent.png" end
                    local new_sprite_file = current_sprite_file:sub( 1, -5 ) .. suffix

                    ComponentSetValue2( iconcomp, "icon_sprite_file", new_sprite_file )
                    ComponentSetValue2( iconcomp, "name", GameTextGetTranslatedOrNot( comp_name ) .. " (spent)" )
                end
            end
        end
    end
end
