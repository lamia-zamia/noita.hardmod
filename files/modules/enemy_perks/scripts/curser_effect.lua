local lerp_amount = 0.993

local function lerp(a, b, weight)
	return a * weight + b * (1 - weight)
end

local function vec_lerp(x1, y1, x2, y2, weight)
	local x = lerp(x1, x2, weight)
	local y = lerp(y1, y2, weight)
	return x,y
end


local materials_to_acid = {
	water = "acid",
	smoke = "flammable_gas",
	spark_red = "spark_green",
}

local entity_id = GetUpdatedEntityID()
local pos_x, pos_y = EntityGetTransform(entity_id)
local parent_id = EntityGetRootEntity(entity_id)
local gec = EntityGetFirstComponent(entity_id, "GameEffectComponent")
local remaining_lifetime = gec and ComponentGetValue2(gec, "frames") or 600

local current_state = EntityGetName(entity_id)
if current_state == "hardmod.curse_cloud_thunder" and remaining_lifetime >= 2700 then
	EntitySetName(entity_id, "hardmod.curse_cloud_acid")
	for _,pec in ipairs(EntityGetComponent(entity_id, "ParticleEmitterComponent") or {}) do
		local current_mat = ComponentGetValue2(pec, "emitted_material_name")
		if materials_to_acid[current_mat] then
			ComponentSetValue2(pec, "emitted_material_name", materials_to_acid[current_mat])
		end
	end

	for _,luacomp in ipairs(EntityGetComponent(entity_id, "LuaComponent") or {}) do
		if ComponentGetValue2(luacomp, "script_source_file") == "data/scripts/status_effects/effect_curse_cloud_thunder.lua" then
			EntitySetComponentIsEnabled(entity_id, luacomp, false) break
		end
	end

	if gec then ComponentSetValue2(gec, "custom_effect_id", "CURSE_CLOUD_02") end

	local ui_icon = EntityGetFirstComponent(entity_id, "UIIconComponent")
	if ui_icon then
		ComponentSetValue2(ui_icon, "name", "$status_curse_cloud_02")
		ComponentSetValue2(ui_icon, "description", "$statusdesc_curse_cloud_02")
	end
elseif current_state == "hardmod.curse_cloud_acid" and remaining_lifetime < 2700 then
	EntitySetName(entity_id, "hardmod.curse_cloud_thunder")

	local materials_to_thunder = {}
	for key, value in pairs(materials_to_acid) do
		materials_to_thunder[value] = key
	end

	for _,pec in ipairs(EntityGetComponent(entity_id, "ParticleEmitterComponent") or {}) do
		local current_mat = ComponentGetValue2(pec, "emitted_material_name")
		if materials_to_thunder[current_mat] then
			ComponentSetValue2(pec, "emitted_material_name", materials_to_thunder[current_mat])
		end
	end

	for _,luacomp in ipairs(EntityGetComponent(entity_id, "LuaComponent") or {}) do
		if ComponentGetValue2(luacomp, "script_source_file") == "data/scripts/status_effects/effect_curse_cloud_thunder.lua" then
			EntitySetComponentIsEnabled(entity_id, luacomp, true) break
		end
	end

	if gec then ComponentSetValue2(gec, "custom_effect_id", "CURSE_CLOUD_01") end

	local ui_icon = EntityGetFirstComponent(entity_id, "UIIconComponent")
	if ui_icon then
		ComponentSetValue2(ui_icon, "name", "$status_curse_cloud_01")
		ComponentSetValue2(ui_icon, "description", "$statusdesc_curse_cloud_01")
	end
end


-- lerp towards target
local target_x, target_y = EntityGetTransform(parent_id)
if target_x == nil then return end

-- move towards target
pos_x, pos_y = vec_lerp(pos_x, pos_y, target_x, target_y, lerp_amount)
EntitySetTransform(entity_id, pos_x, pos_y, 0, 1, 1)
