dofile_once( "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/scripts/perks/toolbox_utils.lua" )

local entity_id = GetUpdatedEntityID()

local wand = EZWand( entity_id )
wand:SetName( "Toolbox", true )
wand.shuffle = false
wand.spellsPerCast = 1
wand.castDelay = 0
wand.rechargeTime = 0
wand.manaMax = 1
wand.mana = 1
wand.manaChargeSpeed = 0
wand.capacity = 20
wand.spread = 0
EntityAddTag( wand.entity_id, "hardmod_toolbox" )
wand:SetSprite( "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/gfx/items/toolbox.png", 5, 2, 4, 3 )

local hm_visits = tonumber( GlobalsGetValue( "HOLY_MOUNTAIN_VISITS", "0" ) )
GenerateToolboxSpells( entity_id, 4 + hm_visits, false )

-- disable spell generation in the biome the toolbox was found in
local x, y = EntityGetTransform( entity_id )
local currbiome = BiomeMapGetName( x, y )
local flag = "toolbox_" .. tostring(currbiome) .. "_visited"
GameAddFlagRun( flag )
