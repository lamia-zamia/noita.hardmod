local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua")---@type utils
local orbs_required = 10
local eid = GetUpdatedEntityID()

current_orb_count = -1

local function update_orb_glyphs(orb_count,player_present,invis)
	if invis and (not player_present) then return end
	local center_x, center_y = EntityGetTransform(eid)
	if utils.GetInternalInt(eid, "hardmod_sampo_orb_glyphs_were_spawned") or 0 == 1 then
		local theta = GameGetFrameNum() / 900 * math.rad(360)
		local rot_step = (math.pi * 2) / orbs_required
		local sway = GameGetFrameNum() / 120 * math.rad(360)
		local glow_count = 0
		local children = EntityGetAllChildren(eid,"hardmod_sampo_orb_glyph")
		local snuffed = true
		for i,orb_glyph in ipairs(children or {}) do
			local glyphcomp = EntityGetFirstComponentIncludingDisabled(orb_glyph, "SpriteComponent")
			local og_alpha = 0.5
			if not glyphcomp then goto continue end
			if glow_count < orb_count then
				local glyph_sprite = ComponentGetValue2(glyphcomp, "image_file")
				if glyph_sprite ~= "mods/noita.hardmod/files/modules/ending/gfx/sampo_orb_indicator_2.png" then
					ComponentSetValue2(glyphcomp, "image_file", "mods/noita.hardmod/files/modules/ending/gfx/sampo_orb_indicator_2.png")
					local fxcomp = EntityGetFirstComponentIncludingDisabled(orb_glyph, "ParticleEmitterComponent")
					if fxcomp then
						ComponentSetValue2(fxcomp,"emission_interval_min_frames",2)
						ComponentSetValue2(fxcomp,"emission_interval_max_frames",2)
					end
				end
				og_alpha = 1
				glow_count = glow_count + 1
			end
			local alpha = ComponentGetValue2(glyphcomp, "alpha")
			if player_present and alpha < og_alpha then
				alpha = math.min(alpha + (og_alpha / 60),og_alpha)
				ComponentSetValue2(glyphcomp, "alpha", alpha)
				utils.SetInternalInt(eid, "hardmod_sampo_orb_glyphs_invisible", 0)
				local fxcomp = EntityGetFirstComponentIncludingDisabled(orb_glyph, "ParticleEmitterComponent")
				if fxcomp then
					ComponentSetValue2(fxcomp, "custom_alpha", alpha * 0.5)
				end
			elseif (not player_present) and alpha > 0 then
				alpha = math.max(alpha - (og_alpha / 60),0)
				ComponentSetValue2(glyphcomp, "alpha", alpha)
				local fxcomp = EntityGetFirstComponentIncludingDisabled(orb_glyph, "ParticleEmitterComponent")
				if fxcomp then
					ComponentSetValue2(fxcomp, "custom_alpha", alpha * 0.5)
				end
				snuffed = false
			end
			local radius = 32 * (alpha / og_alpha)
			local sx = center_x - (radius * math.cos(rot_step * i + theta))
			local sy = center_y - (radius * math.sin(rot_step * i + theta))
			local sr = math.rad(15) * math.sin(sway)
			EntitySetTransform(orb_glyph, sx, sy, sr)

			::continue::
		end
		if (not player_present) and snuffed then
			utils.SetInternalInt(eid, "hardmod_sampo_orb_glyphs_invisible", 1)
		end
		return
	end
	utils.SetInternalInt(eid, "hardmod_sampo_orb_glyphs_were_spawned", 1)
	for i=1, orbs_required do
		local glyph = EntityLoad("mods/noita.hardmod/files/modules/ending/entities/orb_glyph.xml", center_x, center_y)
		utils.SetInternalInt(glyph, "hardmod_sampo_orb_glyph_index", i)
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

	local children = EntityGetAllChildren(eid,"hardmod_sampo_orb_glyph")
	for _,orb_glyph in pairs(children or {}) do
		EntityKill(orb_glyph)
	end
end

local function check_orb_count()
	local comp_id = GetUpdatedComponentID()
	local simulated_execute_n_frame = ComponentGetValue2(comp_id,"mTimesExecuted") % 120 ~= 0
	local orb_count = GameGetOrbCountThisRun()
	if GameHasFlagRun("hardmod_sampo_viewed") then
		local invis = utils.GetInternalInt(eid, "hardmod_sampo_orb_glyphs_invisible") or 0
		if invis == 1 and simulated_execute_n_frame then return end
		local x, y = EntityGetTransform(eid)
		local glyph_detect_radius = 100
		local player_present = EntityGetInRadiusWithTag(x,y,glyph_detect_radius,"player_unit") or {}

		update_orb_glyphs(orb_count,#player_present > 0,invis == 1)
	else
		local wait_frames = 60
		local x, y = EntityGetTransform(eid)
		local interactcomp = EntityGetFirstComponentIncludingDisabled(eid, "InteractableComponent")
		if interactcomp then
			local interact_radius = ComponentGetValue2(interactcomp,"radius")
			local player_present = EntityGetInRadiusWithTag(x,y,interact_radius,"player_unit") or {}
			if #player_present > 0 then
				local frames_viewed = (utils.GetInternalInt(eid, "hardmod_sampo_view_frames") or 0) + 1
				print("frames_viewed: " .. tostring(frames_viewed))
				utils.SetInternalInt(eid, "hardmod_sampo_view_frames", frames_viewed)
				if frames_viewed >= wait_frames then
					GameAddFlagRun("hardmod_sampo_viewed")
				end
			end
		end
	end
	--This is so the script upkeeps its original 'execute_every_n_frame' of 120
	if simulated_execute_n_frame then return end
	update_orb_count(orb_count)

	if orb_count >= orbs_required and not EntityHasTag(eid, "sampo_unlocked") then
		reenable_sampo()
	end
end

function interacting(interactor, entity, name)
	if name ~= "pickup_sampo" then return end
	if not GameHasFlagRun("hardmod_sampo_viewed") then
		GameAddFlagRun("hardmod_sampo_viewed")
	end

	local x, y = EntityGetTransform(entity)

	if current_orb_count < orbs_required then
		GamePlaySound( "data/audio/Desktop/projectiles.snd", "projectiles/magic/create", x, y)
		return
	end
end

check_orb_count()
