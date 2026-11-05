---@diagnostic disable: undefined-global

return {
	new_spells = {
		{
			id					= "HARDMOD_SEA_POISON",
			add_before			= "SEA_MIMIC",
			name				= "$hardmod_spell_sea_poison_name",
			description			= "$hardmod_spell_sea_poison_desc",
			spawn_requires_flag	= "card_unlocked_hardmod_sea_poison",
			sprite				= "mods/noita.hardmod/files/modules/vanilla_quests/spells/sea_poison.png",
			related_projectiles = {"mods/noita.hardmod/files/modules/vanilla_quests/spells/sea_poison.xml"},
			type				= ACTION_TYPE_MATERIAL,
			spawn_level			= "0,4,5,6",
			spawn_probability	= "0.1,0.1,0.4,0.5",
			price				= 350,
			mana				= 140,
			max_uses			= 3,
			action = function()
				add_projectile("mods/noita.hardmod/files/modules/vanilla_quests/spells/sea_poison.xml")
				c.fire_rate_wait = c.fire_rate_wait + 15
			end
		},
	},
	spell_patches = {
		-- Credit to Apotheosis for the idea, sprite and a portion of the code!
		["SEA_MIMIC"] = {
			name = "$hardmod_spell_potion_to_sea_name",
			description = "$hardmod_spell_potion_to_sea_desc",
			sprite = "mods/noita.hardmod/files/modules/vanilla_quests/spells/potion_to_sea.png",
			related_projectiles = {},
			spawn_level = "10",
			spawn_probability = "0",
			spawn_requires_flag = "card_unlocked_hardmod_sea_mimic",
			action = function()
				if reflecting then return end

				local player = GetUpdatedEntityID()
				if not IsPlayer(player) then return end

				local x,y = EntityGetTransform(player)
				local children = EntityGetAllChildren(player) or {}
				local potion = nil

				for _,child in pairs(children) do
					if EntityGetName(child) == "inventory_quick" then
						local items = EntityGetAllChildren(child) or {}
						for _,item in pairs(items) do
							if EntityHasTag(item, "potion") then
								potion = item
								break
							end
						end
						break
					end
				end

				if not potion then return end

				local material = GetMaterialInventoryMainMaterial(potion)
				local proj = EntityLoad("mods/noita.hardmod/files/modules/vanilla_quests/spells/potion_to_sea.xml", x, y)

				local spawner = EntityGetFirstComponent(proj, "MaterialSeaSpawnerComponent")
				if spawner then
					ComponentSetValue2(spawner, "material", material)
				end

				local emitter = EntityGetFirstComponent(proj, "ParticleEmitterComponent")
				if emitter then
					ComponentSetValue2(emitter, "emitted_material_name", CellFactory_GetName(material))
				end

				GamePlaySound("data/audio/Desktop/materials.bank", "collision/glass_potion/destroy", x, y)
				EntityKill(potion)
			end
		},
	}
}
