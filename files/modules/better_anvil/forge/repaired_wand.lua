dofile_once("data/scripts/gun/procedural/gun_procedural_better.lua")
local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )

return function (x, y)
	GamePrint( "GET GENERATED" )

	local wand_entity = EntityLoad( "data/entities/items/wand_level_05_better.xml", x, y )
	local EZWand = dofile_once( "mods/noita.hardmod/lib/ezwand.lua" )
	local wand = EZWand( wand_entity )

	local passives_to_spawn = Random( 1, 3 )

	-- first delete spells if the wand is too full
	for i=1, passives_to_spawn do
		wand:RemoveSpellAtIndex( wand.capacity - ( passives_to_spawn + i ) )
	end

	-- then add passives
	for i=1, passives_to_spawn do
		-- SetRandomSeed(x + i, y - i)
		local spell_id = GetRandomActionWithType( x+i, y-i, 5, ACTION_TYPE_PASSIVE, 666 )
		wand:AddSpells( spell_id )
	end
end
