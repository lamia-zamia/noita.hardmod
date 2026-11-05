local hooks = {}
local nxml = dofile_once("mods/noita.hardmod/lib/nxml/nxml.lua") ---@type nxml


hooks.mod_init = function()
	for xml in nxml.edit_file("data/entities/player_base.xml") do
		xml:add_child(nxml.new_element("LuaComponent", {
			script_damage_received = "mods/noita.hardmod/files/modules/no_more_max_hp_cheesing/scripts/heartbreak_damage_received.lua"
		}))
	end

	for xml in nxml.edit_file("data/entities/misc/effect_hearty.xml") do
		local uicomp = xml:first_of( "UIIconComponent" )
		if uicomp then
			uicomp:set( "description", "$hardmod_status_heartbreak_desc" )
			uicomp:set( "display_above_head", true )
		end
		local luacomp = xml:first_of( "LuaComponent" )
		if luacomp then
			luacomp:set( "script_source_file", "mods/noita.hardmod/files/modules/no_more_max_hp_cheesing/scripts/heartbreak_start.lua" )
		end
		luacomp = xml:nth_of( "LuaComponent", 2 )
		if luacomp then
			luacomp:set( "script_source_file", "mods/noita.hardmod/files/modules/no_more_max_hp_cheesing/scripts/heartbreak_end.lua" )
		end
	end

	for xml in nxml.edit_file("data/entities/projectiles/orb_hearty.xml") do
		local hitfxcomp = xml:first_of( "HitEffectComponent" )
		if hitfxcomp then
			hitfxcomp:set( "effect_hit", "LOAD_UNIQUE_CHILD_ENTITY" )
		end
	end

	-- for luacomp in xml:each_of( "LuaComponent" ) do
	-- 	luacomp:set( "_enabled", false )
	-- end
end

return hooks --Don't forget to do this if you want your changes to apply!!!!