local utils = {} ---@class fungal_effect_utils

function utils.add_effect(owner, base_amount, amount, cooldown, reset_timer)
    for _,child in ipairs(EntityGetAllChildren(owner) or {}) do
    	local name = EntityGetName(child)
    	if name == "hardmod.curse_cloud_thunder" or name == "hardmod.curse_cloud_acid" then
    		local gec = EntityGetFirstComponent(child, "GameEffectComponent")
    		if not gec then return end
            local frame = GameGetFrameNum()
    		if reset_timer then
    			ComponentSetValue2(gec, "frames", amount)
            else
                if frame <= ComponentGetValue2(gec, "teleportation_probability") then return end
                ComponentSetValue2(gec, "frames", ComponentGetValue2(gec, "frames") + amount)
            end
    	end
    end

    local x, y = EntityGetTransform(owner)
    local effect = EntityLoad("mods/noita.hardmod/files/modules/enemy_perks/entities/curser_effect.xml", x, y)
    EntityAddChild(owner, effect)
    local gec = EntityGetFirstComponent(effect, "GameEffectComponent")
    if gec then ComponentSetValue2(gec, "frames", base_amount) end
end

return utils
