dofile_once("data/scripts/game_helpers.lua")

function item_pickup(item, picked_by)
	local damagemodels = EntityGetComponent(picked_by, "DamageModelComponent")
	local x, y = EntityGetTransform(item)

	local max_hp_old = 0
	local max_hp = 0
	local multiplier = tonumber(GlobalsGetValue("HEARTS_MORE_EXTRA_HP_MULTIPLIER", "1")) or 1

	if damagemodels then
		for _,damagemodel in pairs(damagemodels) do
			max_hp = tonumber(ComponentGetValue2(damagemodel, "max_hp")) or 0
			max_hp_old = max_hp
			max_hp = max_hp + 1 * multiplier

			local max_hp_cap = tonumber(ComponentGetValue2(damagemodel, "max_hp_cap"))
			if max_hp_cap > 0 then
				max_hp = math.min(max_hp, max_hp_cap)
			end

			ComponentSetValue2(damagemodel, "mLastMaxHpChangeFrame", GameGetFrameNum())
			ComponentSetValue2(damagemodel, "max_hp_old", max_hp_old)
			ComponentSetValue2(damagemodel, "max_hp", max_hp)
		end
	end

	EntityLoad("data/entities/particles/image_emitters/heart_effect.xml", x, y-12)
	EntityLoad("data/entities/particles/heart_out.xml", x, y-8)

	local description = GameTextGet("$logdesc_heart", tostring(math.floor(max_hp*25)))
	if max_hp == max_hp_old then
		description = GameTextGet("$logdesc_heart_blocked", tostring(math.floor(max_hp*25)))
	else
		heal_entity(picked_by, 1)
	end

	GamePrintImportant("$hardmod_log_pickup_heart_healing", description)
	GameTriggerMusicCue("item")

	EntityKill(item)
end
