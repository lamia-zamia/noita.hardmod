local utils = dofile_once("mods/noita.hardmod/lib/utilities.lua") ---@type utils

-- when the ring breaks, create the portal
function death(damage_type_bit_field, damage_message, entity_thats_responsible, drop_items)
	local ring = GetUpdatedEntityID()
	local x, y = EntityGetTransform(ring)
	local portal = EntityLoad("mods/noita.hardmod/files/modules/holy_mountain_items/entities/portal.xml", x, y)

	if portal ~= nil then
		local tele_comp = EntityGetFirstComponentIncludingDisabled(portal, "TeleportComponent")
		if tele_comp ~= nil then
			local levels = {
				2,
				5,
				9,
				12,
				16,
				20,
				25,
			}

			local y_chunk_level = math.floor(y/512)
			local target_level = 0
			for i,stage_boundary in ipairs(levels) do
				if stage_boundary > y_chunk_level then break end
				target_level = levels[i-1]
			end

			local pw_x,pw_y = GetParallelWorldPosition(x, y)
			local ww,wh = BiomeMapGetSize()
			local offset_x,offset_y = pw_x * ww * 512, pw_y * wh * 512

			ComponentSetValue2(tele_comp, "target", -2 + offset_x, (target_level*512)+386 + offset_y)
			EntitySetComponentIsEnabled(portal, tele_comp, true)
		end
	end
end
