dofile_once( "data/scripts/lib/utilities.lua" )
local utils = dofile_once( "mods/noita.hardmod/lib/utilities.lua" ) ---@type utils

local owner = EntityGetRootEntity( GetUpdatedEntityID() )
local x, y = EntityGetTransform( owner )

-- find an enemy to soul link with
local nearby_enemies = EntityGetInRadiusWithTag( x, y, 115, "enemy" )
if not nearby_enemies or #nearby_enemies == 0 then return end
local candidates = {}
for _,nearby_enemy in ipairs( nearby_enemies ) do
	if nearby_enemy ~= owner and ( utils.GetHerdID( owner ) == utils.GetHerdID( nearby_enemy ) ) then
		table.insert( candidates, nearby_enemy )
	end
end
if not candidates or #candidates == 0 then return end
local linked_enemy = candidates[Random(1, #candidates)]

-- give the enemy's new soul linked ally the perk, too - but only visually
-- eperk_utils.give_enemy_perks(linked_enemy, "SOUL_LINKED", data)
-- for _,cbc in ipairs(EntityGetComponentIncludingDisabled(linked_enemy, "CameraBoundComponent") or {}) do
	-- EntityRemoveComponent(linked_enemy, cbc)
-- end

-- give both enemies the entity id of its ally, so the script can check for their hp

utils.SetInternalInt(linked_enemy, "hardmod_soul_linked_ally", tonumber(owner) or 0)
utils.SetInternalInt(owner, "hardmod_soul_linked_ally", linked_enemy)

-- give both enemies a script that tries to prevent their death
EntityAddComponent2( owner, "LuaComponent", {
	script_damage_received = "mods/noita.hardmod/files/modules/enemy_perks/scripts/soul_linked_on_damage.lua",
	execute_every_n_frame = -1,
})
EntityAddComponent2( linked_enemy, "LuaComponent", {
	script_damage_received = "mods/noita.hardmod/files/modules/enemy_perks/scripts/soul_linked_on_damage.lua",
	execute_every_n_frame = -1,
})

-- remove cbcs
-- for _,cbc in ipairs(EntityGetComponentIncludingDisabled( owner, "CameraBoundComponent" ) or {}) do
-- 	EntityRemoveComponent( owner, cbc )
-- end
-- for _,cbc in ipairs(EntityGetComponentIncludingDisabled( linked_enemy, "CameraBoundComponent" ) or {}) do
-- 	EntityRemoveComponent( linked_enemy, cbc )
-- end

-- give the ally the vfx entity, to draw a particle line
EntityAddChild( linked_enemy, EntityLoad( "mods/noita.hardmod/files/modules/enemy_perks/entities/soul_linked_vfx.xml", x, y ) )

-- finally, destroy this entity
EntityKill( GetUpdatedEntityID() )
