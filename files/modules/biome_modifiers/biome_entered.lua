dofile_once("data/scripts/biome_modifiers.lua")
dofile_once("mods/noita.hardmod/files/modules/biome_modifiers/biome_table.lua")

local last_active_biome = "_EMPTY_"
local active_modifiers = get_modifier_mappings()

GetBiomeTableFromKeys(active_modifiers)

function biome_entered(biome_name)
	local player = GetUpdatedEntityID()

	if last_active_biome == biome_name then return end
	last_active_biome = biome_name

	local effects = EntityGetAllChildren(player, "hardmod_biomemodifier_status") or {}
	for _,effect in pairs(effects) do EntityKill(effect) end

	local biome_id = biome_ui_names[biome_name]
	local modifiers = active_modifiers[biome_id]

	if biome_name == "_EMPTY_" or not biome_id or not modifiers or #modifiers < 1 then
		return
	end

	local root = "mods/noita.hardmod/files/modules/biome_modifiers/"

	for _,modifier in pairs(modifiers) do
		local effect = LoadGameEffectEntityTo(player, root.."entity/status_effect.xml")

		local icon = modifier.status_icon or (root.."gfx/status_effect/"..string.lower(modifier.id)..".png")
		if not ModDoesFileExist(icon) then
			icon = root.."gfx/status_effect/gravity_fields.png"
		end

		local name = GameTextGetTranslatedOrNot(
			modifier.ui_name
			or ("$hardmod_biomemodifier_name_"..string.lower(modifier.id))
		)

		local description = (
			GameTextGetTranslatedOrNot(modifier.ui_description)
			.. "\n" .. GameTextGet("$hardmod_biomemodifier_status")
		)

		EntityAddComponent2(effect, "UIIconComponent", {
			_enabled = true,
			name = name .. " ",
			description = description,
			icon_sprite_file = icon
		})
	end
end
