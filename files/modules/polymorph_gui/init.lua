local hooks = {} ---@type hooks
local _g = HARDMOD_GLOBAL_DATA
local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils


ModLuaFileAppend("data/scripts/status_effects/status_list.lua", "mods/noita.hardmod/files/modules/polymorph_gui/status_list_append.lua")

hooks.player_changed = function()
	if not _g.player_poly_identity then return end

	if not EntityGetFirstComponentIncludingDisabled(_g.player, "InventoryGuiComponent") then
		EntityAddComponent2(_g.player, "InventoryGuiComponent")
		EntityAddComponent2(_g.player, "LuaComponent", {
			script_source_file = "mods/noita.hardmod/files/modules/polymorph_gui/polymorphed_player.lua"
		})
	end

	local polymorphs = {
		POLYMORPH = {
			icon = "mods/noita.hardmod/files/modules/polymorph_gui/polymorphed.png",
			name = "$hardmod_status_polymorph_name",
			desc = "$hardmod_status_polymorph_desc",
		},
		POLYMORPH_UNSTABLE = {
			icon = "mods/noita.hardmod/files/modules/polymorph_gui/chaotic_polymorphed.png",
			name = "$hardmod_status_unstable_polymorph_name",
			desc = "$hardmod_status_unstable_polymorph_desc",
		},
		POLYMORPH_RANDOM = {
			icon = "mods/noita.hardmod/files/modules/polymorph_gui/chaotic_polymorphed.png",
			name = "$hardmod_status_chaotic_polymorph_name",
			desc = "$hardmod_status_chaotic_polymorph_desc",
		},
	}

	if utils.MatchDateLocal({month = 3, day = 31}) then
		polymorphs.POLYMORPH.desc = "$hardmod_status_polymorph_trans_day"
	end

	local rare_polymorph = {
		icon = "mods/noita.hardmod/files/modules/polymorph_gui/rare_chaotic_polymorphed.png",
		name = "$hardmod_status_rare_polymorph_name",
		desc = "$hardmod_status_rare_polymorph_desc",
	}

	for _,rare_poly in pairs(PolymorphTableGet(true)) do
		if _g.player_poly_identity.path == rare_poly then
			local is_rare = true
			for _,common_poly in pairs(PolymorphTableGet(false)) do
				if _g.player_poly_identity.path == common_poly then
					is_rare = false
					break
				end
			end
			if is_rare then polymorphs.POLYMORPH_RANDOM = rare_polymorph end
			break
		end
	end

	for game_effect,data in pairs(polymorphs) do
		local ge_comp = GameGetGameEffect(_g.player, game_effect)
		if ge_comp ~= 0 then
			local ge_entity = ComponentGetEntity(ge_comp)
			local is_perk = false
			if ComponentGetValue2(ge_comp, "frames") < 0 then is_perk = true end
			EntityAddComponent2(ge_entity, "UIIconComponent", {
				icon_sprite_file = data.icon,
				name = data.name,
				description = data.desc,
				is_perk = is_perk
			})
		end
	end
end

return hooks