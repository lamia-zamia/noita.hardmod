---@diagnostic disable: undefined-global

local hooks = {}

hooks.new_perks = {
	{
		id = "HARDMOD_PERK_SPELL_GEMS",
		ui_name = "$hardmod_perk_spell_gems_name",
		ui_description = "$hardmod_perk_spell_gems_desc",
		ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/spell_gems_016.png",
		perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/spell_gems.png",
		stackable = false,
		one_off_effect = false,
		usable_by_enemies = false,
        func = function(entity_perk_item, entity_who_picked, item_name, stacks)
			if stacks > 0 then return end
            EntityAddChild(entity_who_picked, EntityLoad("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/perks/spell_gems.xml"))
        end
	},
	{
		id = "HARDMOD_TINKER_AT_PEDESTALS",
		ui_name = "$hardmod_perk_tinker_at_pedestals_name",
		ui_description = "$hardmod_perk_tinker_at_pedestals_desc",
		ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/tinker_at_pedestals_016.png",
		perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/tinker_at_pedestals.png",
		stackable = false,
		one_off_effect = false,
		usable_by_enemies = false,
		func = function(entity_perk_item, entity_who_picked, item_name, pickup_count)
			if pickup_count > 1 then return end
			EntityAddChild(entity_who_picked, EntityLoad("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/effect_tinker_at_pedestals.xml"))
		end
	},
	{
		id = "HARDMOD_ITEM_IMMUNITIES",
		ui_name = "$hardmod_perk_item_immunities_name",
		ui_description = "$hardmod_perk_item_immunities_desc",
		ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/item_immunities_016.png",
		perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/item_immunities.png",
		stackable = false,
		one_off_effect = false,
		usable_by_enemies = false,
		func = function(perk, player, name, count)
			if count > 1 then return end
			EntityAddChild(player, EntityLoad("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/effect_item_immunities.xml"))
		end
	},
	{
		id = "HARDMOD_PROTECTION_ELECTRIC_STUN",
		ui_name = "$hardmod_perk_protection_electric_stun_name",
		ui_description = "$hardmod_perk_protection_electric_stun_desc",
		ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/protection_electric_stun_016.png",
		perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/protection_electric_stun.png",
		game_effect = "STUN_PROTECTION_ELECTRICITY",
		stackable = false,
		one_off_effect = false,
		usable_by_enemies = false,
		-- given from altar sacrifice
		not_in_default_perk_pool = true,
	},
	{
		id = "HARDMOD_PROTECTION_FREEZE",
		ui_name = "$perk_protection_freeze",
		ui_description = "$perkdesc_protection_freeze",
		ui_icon = "data/ui_gfx/perk_icons/protection_freeze.png",
		perk_icon = "data/items_gfx/perks/protection_freeze.png",
		game_effect = "STUN_PROTECTION_FREEZE",
		stackable = false,
		one_off_effect = false,
		usable_by_enemies = false,
		-- given from altar sacrifice
		not_in_default_perk_pool = true,
	},
	{ --Nabbed from Apotheosis
		id = "HARDMOD_OVERSIZED_SHIELD",
		ui_name = "$hardmod_perk_oversized_shield_name",
		ui_description = "$hardmod_perk_oversized_shield_desc",
		ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/shield_oversized_016.png",
		perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/shield_oversized.png",
		stackable = true,
		stackable_how_often_reappears = 10,
		stackable_maximum = 5,
		max_in_perk_pool = 2,
		usable_by_enemies = false,
		func = function(entity_perk_item, entity_who_picked, item_name, pickup_count)
			local x,y = EntityGetTransform(entity_who_picked)
			local child_id = EntityLoad("mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/perks/shield_oversized.xml", x, y)

			if ModIsEnabled("quant.ew") then
				GlobalsSetValue("PERK_SHIELD_OVERSIZED_COUNT", tostring(pickup_count-1))
			end
			local shield_num = tonumber(GlobalsGetValue("PERK_SHIELD_OVERSIZED_COUNT", "0"))
			local shield_radius = 75 + shield_num * 3.0
			local charge_speed = math.max(0.01 - shield_num * 0.05, 0.02)
			shield_num = shield_num + 1
			GlobalsSetValue("PERK_SHIELD_OVERSIZED_COUNT", tostring(shield_num))

			local comps = EntityGetComponent(child_id, "EnergyShieldComponent")
			for i,comp in ipairs(comps or {}) do
				ComponentSetValue2(comp, "radius", shield_radius)
				ComponentSetValue2(comp, "recharge_speed", charge_speed)
			end

			comps = EntityGetComponent(child_id, "ParticleEmitterComponent")
			for i,comp in ipairs(comps or {}) do
				local minradius,maxradius = ComponentGetValue2(comp, "area_circle_radius")

				if minradius and maxradius then
					if minradius == 0 then
						ComponentSetValue2(comp, "area_circle_radius", 0, shield_radius)
					elseif minradius == 10 then
						ComponentSetValue2(comp, "area_circle_radius", shield_radius, shield_radius)
					end
				end
			end

			EntityAddTag(child_id, "perk_entity")
			EntityAddChild(entity_who_picked, child_id)
		end,
		func_remove = function()
			local shield_num = 0
			GlobalsSetValue("PERK_SHIELD_OVERSIZED_COUNT", tostring(shield_num))
		end,
	},
	{
		id = "HARDMOD_SUMMON_TOOLBOX",
		ui_name = "$hardmod_perk_summon_toolbox_name",
		ui_description = "$hardmod_perk_summon_toolbox_desc",
		ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/summon_toolbox_016.png",
		perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/summon_toolbox.png",
		stackable = STACKABLE_NO,
		one_off_effect = true,
		usable_by_enemies = false,
        func = function( entity_perk_item, entity_who_picked, item_name, pickup_count )
        	if pickup_count > 1 then return end

        	local x, y = EntityGetTransform( entity_who_picked )
        	local toolbox_id = EntityLoad( "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/items/toolbox.xml", x, y - 8 )
        	EntityAddComponent2( toolbox_id, "LuaComponent", {
        		_tags = "enabled_in_hand,enabled_in_inventory",
		        script_source_file = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/scripts/perks/toolbox_scan.lua",
		        execute_every_n_frame = 60,
        	})
        end,
	},
}

hooks.perk_patches = {
	["REMOVE_FOG_OF_WAR"] = {
		ui_name = "$hardmod_perk_all_seeing_eye_name",
		ui_description = "$hardmod_perk_all_seeing_eye_desc",
		ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/all_seeing_eye_016.png",
		perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/all_seeing_eye.png",
		clear_original_game_effect = true,
		stackable = false,
		one_off_effect = false,
		usable_by_enemies = false,
		func = function( entity_perk_item, entity_who_picked, item_name )
			EntityAddChild( entity_who_picked, EntityLoad( "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/entities/perks/all_seeing_eye.xml" ) )
		end,
		func_remove = function( entity_who_picked )
			local perk_entity = EntityGetAllChildren( entity_who_picked, "hardmod_all_seeing_eye_entity" )[1]
			if perk_entity ~= nil then
				EntityKill( perk_entity )
			end
		end,
	},
	["SHIELD"] = { stackable_maximum = 3 },
	-- ["PROTECTION_EXPLOSION"] = {
	-- 	ui_name = "$hardmod_perk_protection_explosion_name",
	-- 	ui_description = "$hardmod_perk_protection_explosion_desc",
	-- 	ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/protection_explosion_016.png",
	-- 	perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/protection_explosion.png",
	-- 	clear_original_game_effect = true,
	-- 	stackable = false,
	-- 	stackable_maximum = 1,
	-- 	func = function( entity_perk_item, entity_who_picked, item_name )
	-- 		local dmg_comp = EntityGetFirstComponent( entity_who_picked, "DamageModelComponent" )
	-- 		if dmg_comp ~= nil then
	-- 			local current_mtp = ComponentObjectGetValue2( dmg_comp, "damage_multipliers", "explosion" )
	-- 			ComponentObjectSetValue2( dmg_comp, "damage_multipliers", "explosion", current_mtp * 0.25 )
	-- 		end
	-- 	end,
	-- 	func_remove = function( entity_who_picked )
	-- 		local dmg_comp = EntityGetFirstComponent( entity_who_picked, "DamageModelComponent" )
	-- 		if dmg_comp ~= nil then
	-- 			local current_mtp = ComponentObjectGetValue2( dmg_comp, "damage_multipliers", "explosion" )
	-- 			ComponentObjectSetValue2( dmg_comp, "damage_multipliers", "explosion", current_mtp * 4 )
	-- 		end
	-- 	end,
	-- },
	-- ["EXPLODING_CORPSES"] = {
	-- 	ui_description = "$hardmod_perk_exploding_corpses_desc",
	-- 	clear_original_game_effect2 = true,
	-- 	remove_other_perks = nil,
	-- 	func = function( entity_perk_item, entity_who_picked, item_name )
	-- 		local dmg_comp = EntityGetFirstComponent( entity_who_picked, "DamageModelComponent" )
	-- 		if dmg_comp ~= nil then
	-- 			local current_mtp = ComponentObjectGetValue2( dmg_comp, "damage_multipliers", "explosion" )
	-- 			ComponentObjectSetValue2( dmg_comp, "damage_multipliers", "explosion", current_mtp * 0.25 )
	-- 		end
	-- 	end,
	-- 	func_remove = function( entity_who_picked )
	-- 		local dmg_comp = EntityGetFirstComponent( entity_who_picked, "DamageModelComponent" )
	-- 		if dmg_comp ~= nil then
	-- 			local current_mtp = ComponentObjectGetValue2( dmg_comp, "damage_multipliers", "explosion" )
	-- 			ComponentObjectSetValue2( dmg_comp, "damage_multipliers", "explosion", current_mtp * 4 )
	-- 		end
	-- 	end,
	-- },
	-- ["PROTECTION_ELECTRICITY"] = {
	-- 	ui_name = "$hardmod_perk_protection_electricity_name",
	-- 	ui_description = "$hardmod_perk_protection_electricity_desc",
	-- 	ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/protection_electricity_016.png",
	-- 	perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/protection_electricity.png",
	-- 	clear_original_game_effect = true,
	-- 	stackable = false,
	-- 	stackable_maximum = 1,
	-- 	func = function( entity_perk_item, entity_who_picked, item_name )
	-- 		local dmg_comp = EntityGetFirstComponent( entity_who_picked, "DamageModelComponent" )
	-- 		if dmg_comp ~= nil then
	-- 			local current_mtp = ComponentObjectGetValue2( dmg_comp, "damage_multipliers", "electricity" )
	-- 			ComponentObjectSetValue2( dmg_comp, "damage_multipliers", "electricity", current_mtp * 0.25 )
	-- 		end
	-- 	end,
	-- 	func_remove = function( entity_who_picked )
	-- 		local dmg_comp = EntityGetFirstComponent( entity_who_picked, "DamageModelComponent" )
	-- 		if dmg_comp ~= nil then
	-- 			local current_mtp = ComponentObjectGetValue2( dmg_comp, "damage_multipliers", "electricity" )
	-- 			ComponentObjectSetValue2( dmg_comp, "damage_multipliers", "electricity", current_mtp * 4 )
	-- 		end
	-- 	end,
	-- },
	-- ["PROTECTION_MELEE"] = {
	-- 	ui_name = "$hardmod_perk_protection_melee_name",
	-- 	ui_description = "$hardmod_perk_protection_melee_desc",
	-- 	ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/protection_melee_016.png",
	-- 	perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/protection_melee.png",
	-- 	clear_original_game_effect = true,
	-- 	stackable = false,
	-- 	stackable_maximum = 1,
	-- 	func = function( entity_perk_item, entity_who_picked, item_name )
	-- 		local dmg_comp = EntityGetFirstComponent( entity_who_picked, "DamageModelComponent" )
	-- 		if dmg_comp ~= nil then
	-- 			local current_mtp = ComponentObjectGetValue2( dmg_comp, "damage_multipliers", "melee" )
	-- 			ComponentObjectSetValue2( dmg_comp, "damage_multipliers", "melee", current_mtp * 0.25 )
	-- 		end
	-- 	end,
	-- 	func_remove = function( entity_who_picked )
	-- 		local dmg_comp = EntityGetFirstComponent( entity_who_picked, "DamageModelComponent" )
	-- 		if dmg_comp ~= nil then
	-- 			local current_mtp = ComponentObjectGetValue2( dmg_comp, "damage_multipliers", "melee" )
	-- 			ComponentObjectSetValue2( dmg_comp, "damage_multipliers", "melee", current_mtp * 4 )
	-- 		end
	-- 	end,
	-- },
	["GOLD_IS_FOREVER"] = { --makes gold decay into special gold dust
		id = "HARDMOD_GOLD_IS_DUST",
		ui_name = "$hardmod_gold_is_dust_perkname",
		ui_description = "$hardmod_gold_is_dust_perkdesc",
		perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/gold_is_dust/perk.png",
		ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/gold_is_dust/icon.png",
		stackable = false,
		func = function()
			GameAddFlagRun("hardmod.gold_is_dust_perk")
		end,
		func_remove = function()
			GameRemoveFlagRun("hardmod.gold_is_dust_perk")
		end,
	},
	["ABILITY_ACTIONS_MATERIALIZED"] = { --works with most spells now, not just a specific selection of bomb spells
		ui_name = "$hardmod_spells_materialised_perkname",
		ui_description = "$hardmod_spells_materialised_perkdesc",
		perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/spells_materialised/perk.png",
		ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/spells_materialised/icon.png",
	},
	["EXTRA_MANA"] = { --buff mana slightly, change 50% decrease in capacity to flat decrease 1-3 plus 10% of current capacity rounded down
		ui_description = "$hardmod_extra_mana_perkdesc",
		func = function(perk, taker, perk_name)
			local wand = GetHeldWand(taker)
			if not wand then return end
			local x,y = EntityGetTransform(wand)

			local ability_comp = EntityGetFirstComponentIncludingDisabled(wand, "AbilityComponent")
			if not ability_comp then return end

			local mana_max = ComponentGetValue2(ability_comp, "mana_max")
			local mana_charge = ComponentGetValue2(ability_comp, "mana_charge_speed")
			local full_capacity = ComponentObjectGetValue2(ability_comp, "gun_config", "deck_capacity") --include ACs
			local capacity = EntityGetWandCapacity(wand) --do not include ACs
			local always_cast_count = math.max(0, full_capacity - capacity)

			local perk_x,perk_y =  EntityGetTransform(perk)
			SetRandomSeed(perk_x, perk_y)

			--lesser of (multiply by 1.3-1.5 OR add 100-500), plus random 100-500
			mana_max = math.min(mana_max * Randomf(1.3, 1.5), mana_max + Random(100, 500))   + Random(100, 200)
			mana_max = math.floor(math.min(mana_max, 50000)) --max of 50k

			--lesser of (multiply by 2-3.5 OR add 80-400), plus random 30-60
			mana_charge = math.min(mana_charge * Randomf(2, 3.5), mana_charge + Random(80, 400))   + Random(30, 60)
			mana_charge = math.floor(math.min(mana_charge, 20000)) --max of 20k

			capacity = math.max(capacity - Random(1, 3) - math.floor(capacity*.1), 1) --remove 1-3 AND one more for every 10 slots it has
			-- (66 slot wand loses 7-9 slots lmao)

			ComponentSetValue2(ability_comp, "mana_max", mana_max)
			ComponentSetValue2(ability_comp, "mana_charge_speed", mana_charge)
			ComponentObjectSetValue2(ability_comp, "gun_config", "deck_capacity", capacity + always_cast_count)


			--nonsense to de-child overflowing spells from capacity decrease
			local c = EntityGetAllChildren(wand)
			if (c ~= nil) and (#c > capacity + always_cast_count) then
				for i=always_cast_count+1,#c do
					local spell = c[i]
					local comp2 = EntityGetFirstComponentIncludingDisabled(spell, "ItemActionComponent")

					if (comp2 ~= nil) and (i > capacity + always_cast_count) then

						EntityRemoveFromParent(spell)
						EntitySetTransform(spell, x, y, 0)

						--fixed tag stuff to properly enabled/disable correct tags (rather than just hard enable all components)
						for _,component in ipairs(EntityGetAllComponents(spell)) do
							if ComponentHasTag(component, "enabled_in_world") then
								EntitySetComponentIsEnabled(spell, component, true)
							else
								EntitySetComponentIsEnabled(spell, component, false)
							end
						end
					end
				end
			end
		end
	},
	["EDIT_WANDS_EVERYWHERE"] = { not_in_default_perk_pool = true },
	["TELEPORTITIS"] = {
		clear_original_game_effect = true,
		ui_description = "$hardmod_perk_teleportitis_desc",
		ui_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/teleportitis_016.png",
		perk_icon = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/ui_gfx/perks/teleportitis.png",
		stackable = false,
		usable_by_enemies = false,
		func = function( entity_perk_item, entity_who_picked, item_name )
			EntityAddComponent2( entity_who_picked, "LuaComponent", {
				_tags = "perk_component,hardmod_teleportitis",
				script_source_file = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/scripts/perks/teleportitis_update.lua",
				execute_every_n_frame = 1,
			} )
			EntityAddComponent2( entity_who_picked, "LuaComponent", {
				_tags = "perk_component,hardmod_teleportitis",
				script_damage_received = "mods/noita.hardmod/files/modules/vanilla_perk_rebalances/scripts/perks/teleportitis_on_damage.lua",
				execute_every_n_frame = -1,
			} )
		end,
		func_remove = function( entity_who_picked )
			EntityRemoveAllByTag( entity_who_picked, "hardmod_teleportitis" )
		end,
	},
	["LOW_RECOIL"] = {
		ui_name = "$hardmod_perk_no_recoil_name",
		ui_description = "$hardmod_perk_no_recoil_desc",
	},
}

local remove_perks = {
	"NO_WAND_EDITING",
	"EXTRA_MONEY", -- replaced by Treasure Hunter
	"PROJECTILE_REPULSION",
	"REVENGE_RATS",
	"VOMIT_RATS",
	"CORDYCEPS",
	"MOLD",
	"FUNGAL_DISEASE",
	"GENOME_MORE_LOVE",
	"LUKKI_MINION",
	"GLOBAL_GORE",
	"PERSONAL_LASER",
	"WORM_ATTRACTOR",
	"WORM_SMALLER_HOLES",
	"DUPLICATE_PROJECTILE",
	"LASER_AIM", -- replaced by Pinpointer spell
	"EXTRA_MANA", -- replaced by Summon Toolbox
	"EXTRA_SLOTS", -- replaced by Summon Toolbox
	"FASTER_WANDS", -- replaced by Summon Toolbox
}

--bomb materialised, lukki mutation, no wand tinkering, more blood, personal plasma beam, low recoil, phasing, pinpointer, proj dupe, levitation trail, worm perks



for _,perk in ipairs(remove_perks) do
	hooks.perk_patches[perk] = { not_in_default_perk_pool = true, not_progress = true }
end

return hooks
