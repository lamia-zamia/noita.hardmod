local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml

for file in nxml.edit_file("data/entities/animals/boss_alchemist/boss_alchemist.xml") do
	file:create_child("LuaComponent", {
		script_damage_about_to_be_received = "mods/noita.hardmod/files/vanilla_bosses/scripts/alchemist_anticheese.lua"
	})
end

utils.patchifile("data/entities/animals/boss_alchemist/projectile_counter_create.lua", {
	{
		from = [[local entity_id]],
		insert_before = [[
		do
			local comp = EntityGetFirstComponent(GetUpdatedEntityID(),"HitboxComponent")
			if comp and ComponentGetValue2(comp,"damage_multiplier") <= 0.01 then return end
		end
		]]
	},
	{
		from = [[ComponentSetValue2( c, "execute_every_n_frame", 600 )]],
		to = [[
			ComponentSetValue2( c, "execute_every_n_frame", 660 )
			ComponentSetValue2( c, "mNextExecutionTime", GameGetFrameNum() + 660 )
		]]
	}
})

utils.patchifile("data/entities/animals/boss_alchemist/projectile_counter_create_damage.lua", {
	{
		from = [[local eid = EntityLoad( "data/entities/animals/boss_alchemist/projectile_counter.xml", x, y )]],
		to = [[dofile("data/entities/animals/boss_alchemist/projectile_counter_create.lua")]]
	},
	{
		from = [[EntityAddChild( entity_id, eid )]],
		to = " "
	},
	{ from = [[cumulative >= 3.0]], to = [[cumulative >= 7.0]] },
	{ from = [[cumulative = cumulative - 3.0]], to = [[cumulative = -7.0]] },
})
