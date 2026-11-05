local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils
local orbs_required = 10
local eid = GetUpdatedEntityID()

current_orb_count = -1

local function update_orb_glyphs(orb_count)
	if utils.GetInternalInt(eid, "hardmod_sampo_orb_glyphs_were_spawned") or 0 == 1 then return end
	utils.SetInternalInt(eid, "hardmod_sampo_orb_glyphs_were_spawned", 1)

	local rot_step = (math.pi * 2) / orbs_required
	local center_x, center_y = EntityGetTransform(eid)
	for i=0, orbs_required-1 do
		local sx = center_x - (32 * math.cos(rot_step * i)) - 6
		local sy = center_y - (32 * math.sin(rot_step * i))
		local glyph = EntityLoad("mods/noita.hardmod/files/modules/ending/entities/orb_glyph.xml", sx, sy)
		utils.SetInternalInt(glyph, "hardmod_sampo_orb_glyph_index", i+1)
		EntityAddChild(eid, glyph)
	end
end

local function update_orb_count(orb_count)
	if orb_count == current_orb_count then return end

	local interaction = EntityGetFirstComponentIncludingDisabled(eid, "InteractableComponent")
	if interaction then
		local tooltip = GameTextGet("$hardmod_sampo_tooltip", tostring(orb_count), tostring(orbs_required))
		ComponentSetValue2(interaction, "ui_text", tooltip)
	end

	current_orb_count = orb_count
	-- update_orb_glyphs(orb_count)
end

local function reenable_sampo()
	if EntityHasTag(eid, "sampo_unlocked") then return end

	local emitters = EntityGetComponentIncludingDisabled(eid, "ParticleEmitterComponent") or {}
	for _,comp in pairs(emitters) do
		if ComponentGetValue2(comp, "emitted_material_name") == "spark_white_bright" then
			ComponentSetValue2(comp, "emitted_material_name", "spark_blue")
		end
	end

	local sprite = EntityGetFirstComponentIncludingDisabled(eid, "SpriteComponent")
	if sprite then
		ComponentSetValue2(sprite, "image_file", "mods/noita.hardmod/files/modules/ending/gfx/sampo_sprite.xml")
	end

	local interactable = EntityGetFirstComponentIncludingDisabled(eid, "InteractableComponent")
	if interactable then
		EntityRemoveComponent(eid, interactable)
	end

	EntityAddComponent2(eid, "ItemComponent", {
		_tags = "enabled_in_world",
		item_name = "$item_mcguffin_10",
		is_pickable = true,
		ui_sprite = "data/ui_gfx/items/sampo.png",
		ui_description = "$itemdesc_mcguffin_10",
		preferred_inventory = "FULL",
		uses_remaining = -1,
		play_spinning_animation = false,
		play_hover_animation = true
	})

	EntityAddTag(eid, "sampo_unlocked")
end

local function check_orb_count()
	local orb_count = GameGetOrbCountThisRun()
	update_orb_count(orb_count)

	if orb_count >= orbs_required and not EntityHasTag(eid, "sampo_unlocked") then
		reenable_sampo()
	end
end

function interacting(interactor, entity, name)
	if name ~= "pickup_sampo" then return end

	local x, y = EntityGetTransform(entity)

	if current_orb_count < orbs_required then
		GamePlaySound( "data/audio/Desktop/projectiles.snd", "projectiles/magic/create", x, y)
		return
	end
end

check_orb_count()
