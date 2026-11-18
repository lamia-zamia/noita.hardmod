local ability_id = GetUpdatedEntityID()
local host_id = EntityGetRootEntity(ability_id)
local brain_id = 0
local tier = 1

local children = EntityGetAllChildren(host_id) or {}
for _,child in ipairs(children) do
    if EntityGetName(child) == "felcesis_brain" then
		local vsc = EntityGetFirstComponentIncludingDisabled(child,"VariableStorageComponent")
		tier = vsc and ComponentGetValue2(vsc, "value_float") or 1

		break
    end
end

local vsc_comp = EntityGetFirstComponentIncludingDisabled(ability_id,"VariableStorageComponent")
if not vsc_comp then return end
local damagetype = ComponentGetValue2(vsc_comp,"value_string")
local dmg_comp = EntityGetFirstComponentIncludingDisabled(host_id,"DamageModelComponent")

local damage_mult = 0
local required_tier_for_immunity = damagetype == "projectile" and 7 or 5
if tier < required_tier_for_immunity then
    --Only have 65% damage resistance until Ira is tier 5 (tier 7 for projectile damage), at which point they gain full damage immunity against a given type
    damage_mult = 0.35
    local ui_comp = EntityGetFirstComponentIncludingDisabled(ability_id,"UIIconComponent")
	if ui_comp then
		local ui_icon_filepath = ComponentGetValue2(ui_comp,"icon_sprite_file")
		ComponentSetValue2(ui_comp,"icon_sprite_file",ui_icon_filepath:gsub("protection_","protection_soft_"))
	end
end

if dmg_comp then
	ComponentObjectSetValue2(dmg_comp,"damage_multipliers",damagetype,damage_mult)
end
