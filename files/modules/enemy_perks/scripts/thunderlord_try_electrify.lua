
local proj_id = GetUpdatedEntityID()
local proj_comp = EntityGetFirstComponent(proj_id, "ProjectileComponent")
if proj_comp then
	local lightning_count = ComponentObjectGetValue2(proj_comp, "config", "lightning_count") or -1
	local electricity_count = ComponentObjectGetValue2(proj_comp, "config_explosion", "electricity_count") or -1
	ComponentObjectSetValue2(proj_comp, "config", "lightning_count", lightning_count + 1)
	ComponentObjectSetValue2(proj_comp, "config_explosion", "electricity_count", electricity_count + 1)
end
